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
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY")

# Твой ID прописан прямо тут, чтобы кнопка 100% появилась
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
    if user_id == ADMIN_ID:
        kb.insert(1, [KeyboardButton(text="🛠 Починить репозиторий (ИИ)")])
    return ReplyKeyboardMarkup(keyboard=kb, resize_keyboard=True)

@dp.message(CommandStart())
async def start(msg: Message):
    await msg.answer(
        "Привет! Я бот-компилятор Pawn.\n"
        "Скинь мне ZIP с модом для компиляции.",
        reply_markup=get_main_keyboard(msg.from_user.id)
    )

@dp.message(F.text == "🚀 Начать")
async def start_btn(msg: Message):
    await start(msg)

@dp.message(F.text == "❓ Помощь")
async def help_msg(msg: Message):
    await msg.answer("1. Скинь ZIP-архив с модом.\n2. Забери готовый .amx.")

@dp.message(F.text == "📂 Отправить мод ZIP")
async def send_zip_msg(msg: Message):
    await msg.answer("Жду твой ZIP-архив! 📦")

# --- ИИ РЕМОНТ ---
@dp.message(F.text == "🛠 Починить репозиторий (ИИ)")
async def fix_repo(msg: Message):
    if msg.from_user.id != ADMIN_ID:
        return await msg.answer("⛔ У тебя нет прав на это действие.")

    await msg.answer("🧠 Скачиваю последний лог ошибки и файл compile.yml...")

    runs = requests.get(f"https://api.github.com/repos/{REPO}/actions/runs", headers=gh_headers).json()
    run = next((r for r in runs["workflow_runs"] if r["name"] == "Compile Pawn"), None)

    if not run or run["conclusion"] != "failure":
        return await msg.answer("✅ Последняя компиляция не падала (или логов нет).")

    log_url = f"https://api.github.com/repos/{REPO}/actions/runs/{run['id']}/logs"
    log_resp = requests.get(log_url, headers=gh_headers, allow_redirects=True)
    
    error_text = ""
    if log_resp.status_code == 200:
        with zipfile.ZipFile(io.BytesIO(log_resp.content)) as z:
            log_file = [f for f in z.namelist() if "Compile" in f or "compile" in f][0]
            log_text = z.read(log_file).decode("utf-8", errors="replace")
            error_text = "\n".join([l for l in log_text.splitlines() if "error" in l.lower()])

    yml_url = f"https://api.github.com/repos/{REPO}/contents/.github/workflows/compile.yml"
    yml_resp = requests.get(yml_url, headers=gh_headers).json()
    yml_content = base64.b64decode(yml_resp["content"]).decode("utf-8")

    await msg.answer("🧠 Отправляю данные ИИ (DeepSeek), он думает...")

    ai_url = "https://api.deepseek.com/v1/chat/completions"
    ai_headers = {"Authorization": f"Bearer {DEEPSEEK_API_KEY}", "Content-Type": "application/json"}
    prompt = f"Ты — эксперт по GitHub Actions и Pawn. У меня упала компиляция.\nВот лог ошибки:\n{error_text}\n\nВот текущий файл compile.yml:\n{yml_content}\n\nНапиши ТОЛЬКО исправленный код файла compile.yml. Без лишних слов, без markdown-тегов, просто код."
    
    ai_data = {"model": "deepseek-chat", "messages": [{"role": "user", "content": prompt}]}
    ai_resp = requests.post(ai_url, headers=ai_headers, json=ai_data)

    if ai_resp.status_code != 200:
        return await msg.answer(f"❌ Ошибка ИИ: {ai_resp.text}")

    new_yml = ai_resp.json()["choices"][0]["message"]["content"]
    new_yml = new_yml.replace("```yaml", "").replace("```", "").strip()

    await msg.answer(f"📝 **ИИ предлагает код:**\n\n`{new_yml[:1000]}...`\n\nПрименить?", 
                     reply_markup=ReplyKeyboardMarkup(keyboard=[[KeyboardButton(text="✅ Применить")]], resize_keyboard=True))

    global pending_fix
    pending_fix = {"content": new_yml, "sha": yml_resp["sha"]}

@dp.message(F.text == "✅ Применить")
async def apply_fix(msg: Message):
    if msg.from_user.id != ADMIN_ID:
        return await msg.answer("⛔ У тебя нет прав.")
    
    if 'pending_fix' not in globals():
        return await msg.answer("Нет ожидающих исправлений.")

    url = f"https://api.github.com/repos/{REPO}/contents/.github/workflows/compile.yml"
    data = {
        "message": "AI Auto-Fix compile.yml",
        "content": base64.b64encode(pending_fix["content"].encode()).decode(),
        "sha": pending_fix["sha"]
    }
    requests.put(url, headers=gh_headers, json=data)
    
    await msg.answer("✅ Файл обновлен! Скинь архив заново для проверки.")
    del pending_fix

# --- КОМПИЛЯЦИЯ ---
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
            requests.put(url, headers=gh_headers, json={"message": "Upload", "content": content})
    
    await msg.answer("🚀 Файлы загружены. Запускаю компиляцию...")
    
    wf_url = f"https://api.github.com/repos/{REPO}/actions/workflows/compile.yml/dispatches"
    requests.post(wf_url, headers=gh_headers, json={"ref": "main", "inputs": {"request_id": request_id, "source_dir": temp_dir}})
    
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
                await msg.answer("❌ Ошибка компиляции. Нажми '🛠 Починить репозиторий (ИИ)'.")
                return

async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
