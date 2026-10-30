import os
import time
import requests
import zipfile
import io
import base64
import asyncio
from aiogram import Bot, Dispatcher, F
from aiogram.types import Message, FSInputFile
from aiogram.filters import CommandStart
from dotenv import load_dotenv

load_dotenv()

# --- НАСТРОЙКИ ---
# Токены берутся из секретов GitHub (мы их туда добавили)
BOT_TOKEN = os.getenv("BOT_TOKEN")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")

# ВАЖНО: Укажи здесь свой ник и название репозитория!
REPO = "progra-mist/Botpwn" 

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

headers = {
    "Authorization": f"Bearer {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}

@dp.message(CommandStart())
async def start(msg: Message):
    await msg.answer("Привет! Я бот-компилятор Pawn.\nСкинь мне ZIP-архив с твоим модом (внутри должен быть .pwn и папка с инклюдами).")

@dp.message(F.document)
async def handle_zip(msg: Message):
    if not msg.document.file_name.endswith(".zip"):
        return await msg.answer("Нужен именно ZIP-архив!")
    
    await msg.answer("⏳ Скачиваю и распаковываю архив...")
    request_id = str(int(time.time()))
    temp_dir = f"temp_compile/{request_id}"
    
    # Скачиваем ZIP из ТГ
    file = await bot.get_file(msg.document.file_id)
    downloaded = await bot.download_file(file.file_path)
    zip_data = downloaded.read()
    
    # Распаковываем и загружаем на GitHub
    with zipfile.ZipFile(io.BytesIO(zip_data)) as z:
        for file_info in z.infolist():
            if file_info.is_dir():
                continue
            
            # Загружаем только .pwn и .inc
            if not (file_info.filename.endswith(".pwn") or file_info.filename.endswith(".inc")):
                continue
                
            content = base64.b64encode(z.read(file_info.filename)).decode()
            url = f"https://api.github.com/repos/{REPO}/contents/{temp_dir}/{file_info.filename}"
            
            requests.put(url, headers=headers, json={
                "message": f"Upload {file_info.filename}",
                "content": content
            })
    
    await msg.answer("🚀 Файлы загружены. Запускаю компиляцию...")
    
    # Запускаем workflow
    wf_url = f"https://api.github.com/repos/{REPO}/actions/workflows/compile.yml/dispatches"
    requests.post(wf_url, headers=headers, json={
        "ref": "main",
        "inputs": {"request_id": request_id, "source_dir": temp_dir}
    })
    
    # Ждем завершения
    for _ in range(40):
        await asyncio.sleep(5)
        runs = requests.get(f"https://api.github.com/repos/{REPO}/actions/runs", headers=headers).json()
        run = next((r for r in runs["workflow_runs"] if r["name"] == "Compile Pawn"), None)
        
        if run and run["status"] == "completed":
            if run["conclusion"] == "success":
                # Скачиваем артефакт
                arts = requests.get(run["artifacts_url"], headers=headers).json()
                if not arts["artifacts"]:
                    return await msg.answer("❌ Артефакт не найден.")
                
                dl_url = arts["artifacts"][0]["archive_download_url"]
                zip_resp = requests.get(dl_url, headers=headers).content
                
                # Достаем .amx
                with zipfile.ZipFile(io.BytesIO(zip_resp)) as z:
                    z.extractall("temp_out")
                    amx_file = [f for f in os.listdir("temp_out") if f.endswith(".amx")][0]
                
                await msg.answer_document(FSInputFile(f"temp_out/{amx_file}"), caption="✅ Успешно скомпилировано!")
                os.remove(f"temp_out/{amx_file}")
                os.rmdir("temp_out")
                return
            else:
                return await msg.answer("❌ Ошибка компиляции. Проверь код и инклюды.")
    
    await msg.answer("⌛ GitHub слишком долго думает. Попробуй позже.")

async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
