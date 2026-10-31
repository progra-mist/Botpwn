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

# --- НАСТРОЙКИ ---
BOT_TOKEN = os.getenv("BOT_TOKEN")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
ADMIN_ID = 8827502259 
REPO = "progra-mist/Botpwn" 

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

gh_headers = {
    "Authorization": f"Bearer {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}

# --- КНОПКИ ---
def get_main_keyboard(user_id):
    kb = [
        [KeyboardButton(text="🚀 Начать")],
        [KeyboardButton(text="📂 Отправить мод ZIP")],
        [KeyboardButton(text="❓ Помощь")]
    ]
    return ReplyKeyboardMarkup(keyboard=kb, resize_keyboard=True)

@dp.message(CommandStart())
async def start(msg: Message):
    await msg.answer("Привет! Я бот-компилятор Pawn.\nСкинь мне ZIP с модом для компиляции.", reply_markup=get_main_keyboard(msg.from_user.id))

@dp.message(F.text == "🚀 Начать")
async def start_btn(msg: Message):
    await start(msg)

@dp.message(F.text == "❓ Помощь")
async def help_msg(msg: Message):
    await msg.answer("1. Скинь ZIP-архив с модом.\n2. Забери готовый .amx.\nЕсли ошибка — я пришлю лог файлом.")

@dp.message(F.text == "📂 Отправить мод ZIP")
async def send_zip_msg(msg: Message):
    await msg.answer("Жду твой ZIP-архив! 📦")

# --- АНИМАЦИЯ ПРОГРЕСС-БАРА ---
async def animate_progress(message: Message, stop_event: asyncio.Event):
    # Имитация прогресса (просто для красоты)
    stages = [
        "📥 Скачиваю архив...",
        "📦 Распаковываю...",
        "☁️ Загружаю на GitHub...",
        "⚙️ Запускаю компилятор..."
    ]
    
    for i in range(1, 101, 10):
        if stop_event.is_set():
            break
        # Рисуем квадратики
        filled = int(i / 10)
        empty = 10 - filled
        bar = "■" * filled + "□" * empty
        
        text = f"⏳ <b>Обработка архива</b>\n\n[{bar}] {i}%\n\n<i>{stages[min(filled-1, 3)]}</i>"
        try:
            await message.edit_text(text, parse_mode="HTML")
        except:
            pass # Игнорируем ошибки редактирования (если сообщение не изменилось)
        
        await asyncio.sleep(0.8)

# --- КОМПИЛЯЦИЯ ---
@dp.message(F.document)
async def handle_zip(msg: Message):
    if not msg.document.file_name.endswith(".zip"):
        return await msg.answer("Нужен именно ZIP-архив!")
    
    # Отправляем сообщение для прогресс-бара
    progress_msg = await msg.answer("⏳ <b>Начинаю обработку...</b>", parse_mode="HTML")
    
    # Запускаем анимацию в фоне
    stop_event = asyncio.Event()
    progress_task = asyncio.create_task(animate_progress(progress_msg, stop_event))
    
    try:
        # Скачиваем и загружаем
        request_id = str(int(time.time()))
        temp_dir = f"temp_compile/{request_id}"
        
        file = await bot.get_file(msg.document.file_id)
        downloaded = await bot.download_file(file.file_path)
        zip_data = downloaded.read()
        
        with zipfile.ZipFile(io.BytesIO(zip_data)) as z:
            for file_info in z.infolist():
                if file_info.is_dir(): continue
                if not (file_info.filename.endswith(".pwn") or file_info.filename.endswith(".inc") or file_info.filename.endswith(".lang")): continue
                    
                content = base64.b64encode(z.read(file_info.filename)).decode()
                url = f"https://api.github.com/repos/{REPO}/contents/{temp_dir}/{file_info.filename}"
                requests.put(url, headers=gh_headers, json={"message": "Upload", "content": content})
    finally:
        # Останавливаем анимацию
        stop_event.set()
        await progress_task
        await progress_msg.edit_text("🚀 <b>Файлы загружены! Жду компилятор...</b>", parse_mode="HTML")
    
    # Запускаем workflow
    wf_url = f"https://api.github.com/repos/{REPO}/actions/workflows/compile.yml/dispatches"
    requests.post(wf_url, headers=gh_headers, json={"ref": "main", "inputs": {"request_id": request_id, "source_dir": temp_dir}})
    
    # Ждем компиляции
    for _ in range(40):
        await asyncio.sleep(5)
        runs = requests.get(f"https://api.github.com/repos/{REPO}/actions/runs", headers=gh_headers).json()
        run = next((r for r in runs["workflow_runs"] if r["name"] == "Compile Pawn"), None)
        
        if run and run["status"] == "completed":
            if run["conclusion"] == "success":
                arts = requests.get(run["artifacts_url"], headers=gh_headers).json()
                dl_url = arts["artifacts"][0]["archive_download_url"]
                zip_resp = requests.get(dl_url, headers=gh_headers).content
                with zipfile.ZipFile(io.BytesIO(zip_resp)) as z:
                    z.extractall("temp_out")
                    amx_file = [f for f in os.listdir("temp_out") if f.endswith(".amx")][0]
                await msg.answer_document(FSInputFile(f"temp_out/{amx_file}"), caption="✅ Успешно скомпилировано!")
                os.remove(f"temp_out/{amx_file}")
                os.rmdir("temp_out")
                return
            else:
                # Скачиваем лог и отправляем как .txt
                logs_url = f"https://api.github.com/repos/{REPO}/actions/runs/{run['id']}/logs"
                log_resp = requests.get(logs_url, headers=gh_headers, allow_redirects=True)
                
                if log_resp.status_code == 200:
                    with zipfile.ZipFile(io.BytesIO(log_resp.content)) as z:
                        log_file = [f for f in z.namelist() if "Compile" in f or "compile" in f][0]
                        log_text = z.read(log_file).decode("utf-8", errors="replace")
                        
                        with open("error_log.txt", "w", encoding="utf-8") as f:
                            f.write(log_text)
                            
                        await msg.answer_document(FSInputFile("error_log.txt"), caption="❌ Ошибка компиляции. Вот полный лог:")
                        os.remove("error_log.txt")
                else:
                    await msg.answer("❌ Ошибка компиляции. Не удалось скачать лог.")
                return
    
    await msg.answer("⌛ GitHub слишком долго думает. Попробуй позже.")

async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
