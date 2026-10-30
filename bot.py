import os
import time
import requests
import zipfile
import io
import base64
import asyncio
from aiogram import Bot, Dispatcher, F
from aiogram.types import Message, FSInputFile, ReplyKeyboardMarkup, KeyboardButton
from aiogram.filters import CommandStart
from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
REPO = "progra-mist/Botpwn" 

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

headers = {
    "Authorization": f"Bearer {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}

def get_main_keyboard():
    kb = [
        [KeyboardButton(text="📂 Отправить мод ZIP")],
        [KeyboardButton(text="⚙️ Инструменты"), KeyboardButton(text="❓ Как пользоваться")]
    ]
    return ReplyKeyboardMarkup(keyboard=kb, resize_keyboard=True)

@dp.message(CommandStart())
async def start(msg: Message):
    await msg.answer(
        "Привет! Я бот-компилятор Pawn.\n"
        "Нажми на кнопку ниже, чтобы отправить архив, или просто скинь мне ZIP-файл.",
        reply_markup=get_main_keyboard()
    )

@dp.message(F.text == "❓ Как пользоваться")
async def how_to_use(msg: Message):
    await msg.answer(
        "1. Заархивируй папку с модом в ZIP.\n"
        "2. Внутри обязательно должен быть файл `.pwn` и папка `include`.\n"
        "3. Отправь архив сюда.\n"
        "4. Забери готовый `.amx`!"
    )

@dp.message(F.text == "⚙️ Инструменты")
async def tools(msg: Message):
    await msg.answer(
        "Компилятор: Pawn 3.10.10\n"
        "Сервер: GitHub Actions\n"
        "Лимит: Бесплатно"
    )

@dp.message(F.text == "📂 Отправить мод ZIP")
async def send_zip_msg(msg: Message):
    await msg.answer("Жду твой ZIP-архив! 📦")

@dp.message(F.document)
async def handle_zip(msg: Message):
    if not msg.document.file_name.endswith(".zip"):
        return await msg.answer("Нужен именно ZIP-архив!")
    
    await msg.answer("⏳ Скачиваю и распаковываю архив...")
    request_id = str(int(time.time()))
    temp_dir = f"temp_compile/{request_id}"
    
    file = await bot.get_file(msg.document.file_id)
    downloaded = await bot.download_file(file.file_path)
    zip_data = downloaded.read()
    
    with zipfile.ZipFile(io.BytesIO(zip_data)) as z:
        for file_info in z.infolist():
            if file_info.is_dir(): continue
            if not (file_info.filename.endswith(".pwn") or file_info.filename.endswith(".inc")): continue
                
            content = base64.b64encode(z.read(file_info.filename)).decode()
            url = f"https://api.github.com/repos/{REPO}/contents/{temp_dir}/{file_info.filename}"
            requests.put(url, headers=headers, json={"message": "Upload", "content": content})
    
    await msg.answer("🚀 Файлы загружены. Запускаю компиляцию...")
    
    wf_url = f"https://api.github.com/repos/{REPO}/actions/workflows/compile.yml/dispatches"
    requests.post(wf_url, headers=headers, json={"ref": "main", "inputs": {"request_id": request_id, "source_dir": temp_dir}})
    
    for _ in range(40):
        await asyncio.sleep(5)
        runs = requests.get(f"https://api.github.com/repos/{REPO}/actions/runs", headers=headers).json()
        run = next((r for r in runs["workflow_runs"] if r["name"] == "Compile Pawn"), None)
        
        if run and run["status"] == "completed":
            if run["conclusion"] == "success":
                arts = requests.get(run["artifacts_url"], headers=headers).json()
                if not arts["artifacts"]:
                    return await msg.answer("❌ Артефакт не найден.")
                dl_url = arts["artifacts"][0]["archive_download_url"]
                zip_resp = requests.get(dl_url, headers=headers).content
                with zipfile.ZipFile(io.BytesIO(zip_resp)) as z:
                    z.extractall("temp_out")
                    amx_file = [f for f in os.listdir("temp_out") if f.endswith(".amx")][0]
                await msg.answer_document(FSInputFile(f"temp_out/{amx_file}"), caption="✅ Успешно скомпилировано!")
                os.remove(f"temp_out/{amx_file}")
                os.rmdir("temp_out")
                return
            else:
                # --- ВОТ ТУТ МЫ ДОБАВИЛИ СКАЧИВАНИЕ ЛОГА ---
                logs_url = f"https://api.github.com/repos/{REPO}/actions/runs/{run['id']}/logs"
                log_resp = requests.get(logs_url, headers=headers, allow_redirects=True)
                
                if log_resp.status_code == 200:
                    with zipfile.ZipFile(io.BytesIO(log_resp.content)) as z:
                        # Ищем файл лога компиляции
                        log_file = [f for f in z.namelist() if "Compile" in f or "compile" in f][0]
                        log_text = z.read(log_file).decode("utf-8", errors="replace")
                        
                        # Берем последние 15 строк (самое важное)
                        lines = log_text.splitlines()
                        last_lines = "\n".join(lines[-15:])
                        
                        await msg.answer(f"❌ Ошибка компиляции!\n\n<b>Лог:</b>\n<pre>{last_lines}</pre>", parse_mode="HTML")
                else:
                    await msg.answer("❌ Ошибка компиляции. Не удалось скачать лог.")
                return
    
    await msg.answer("⌛ GitHub слишком долго думает. Попробуй позже.")

async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
    
