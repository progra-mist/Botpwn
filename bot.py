import os
import time
import requests
import zipfile
import io
import base64
import asyncio
import sqlite3
from datetime import datetime, timedelta
from aiogram import Bot, Dispatcher, F
from aiogram.types import Message, FSInputFile, ReplyKeyboardMarkup, KeyboardButton, LabeledPrice, PreCheckoutQuery
from aiogram.filters import CommandStart
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from dotenv import load_dotenv

load_dotenv()

# --- НАСТРОЙКИ ---
BOT_TOKEN = os.getenv("BOT_TOKEN")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
ADMIN_ID = 8827502259 
REPO = "progra-mist/Botpwn" 

PREMIUM_PRICE = 5 # Цена в звездах (5 ⭐)
DAILY_LIMIT = 3

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

gh_headers = {
    "Authorization": f"Bearer {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}

# --- СОСТОЯНИЯ ДЛЯ ПРОМОКОДОВ ---
class PromoState(StatesGroup):
    waiting_for_name = State()
    waiting_for_days = State()

# --- БАЗА ДАННЫХ ---
def init_db():
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS users
                 (user_id INTEGER PRIMARY KEY, 
                  premium_until TEXT,
                  daily_count INTEGER,
                  last_date TEXT)''')
    c.execute('''CREATE TABLE IF NOT EXISTS promocodes
                 (code TEXT PRIMARY KEY, 
                  days INTEGER, 
                  used_by TEXT)''')
    conn.commit()
    conn.close()

def get_user_data(user_id):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("SELECT premium_until, daily_count, last_date FROM users WHERE user_id = ?", (user_id,))
    row = c.fetchone()
    today = datetime.now().strftime("%Y-%m-%d")
    
    if not row:
        c.execute("INSERT INTO users (user_id, daily_count, last_date) VALUES (?, 0, ?)", (user_id, today))
        conn.commit()
        conn.close()
        return {"premium_until": None, "daily_count": 0}
    
    premium_until, daily_count, last_date = row
    if last_date != today:
        c.execute("UPDATE users SET daily_count = 0, last_date = ? WHERE user_id = ?", (today, user_id))
        conn.commit()
        daily_count = 0
    conn.close()
    return {"premium_until": premium_until, "daily_count": daily_count}

def update_user_count(user_id):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("UPDATE users SET daily_count = daily_count + 1 WHERE user_id = ?", (user_id,))
    conn.commit()
    conn.close()

def set_premium(user_id, days):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    # Если уже есть премиум, добавляем дни к текущей дате
    c.execute("SELECT premium_until FROM users WHERE user_id = ?", (user_id,))
    row = c.fetchone()
    
    if row and row[0]:
        current_premium = datetime.strptime(row[0], "%Y-%m-%d %H:%M:%S")
        if current_premium > datetime.now():
            premium_until = (current_premium + timedelta(days=days)).strftime("%Y-%m-%d %H:%M:%S")
        else:
            premium_until = (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d %H:%M:%S")
    else:
        premium_until = (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d %H:%M:%S")
        
    c.execute("UPDATE users SET premium_until = ? WHERE user_id = ?", (premium_until, user_id))
    conn.commit()
    conn.close()

def check_premium(user_id):
    if user_id == ADMIN_ID: return True 
    data = get_user_data(user_id)
    if data["premium_until"]:
        premium_date = datetime.strptime(data["premium_until"], "%Y-%m-%d %H:%M:%S")
        if premium_date > datetime.now():
            return True
    return False

# --- КНОПКИ ---
def get_main_keyboard(user_id):
    kb = [
        [KeyboardButton(text="🚀 Начать")],
        [KeyboardButton(text="💎 Купить Премиум"), KeyboardButton(text="👤 Профиль")],
        [KeyboardButton(text="🎁 Ввести промокод")],
        [KeyboardButton(text="📂 Отправить мод ZIP")],
        [KeyboardButton(text="❓ Помощь")]
    ]
    if user_id == ADMIN_ID:
        kb.insert(2, [KeyboardButton(text="🛠 Создать промокод")])
    return ReplyKeyboardMarkup(keyboard=kb, resize_keyboard=True)

@dp.message(CommandStart())
async def start(msg: Message):
    init_db()
    data = get_user_data(msg.from_user.id)
    prem = "💎 Премиум" if check_premium(msg.from_user.id) else "🆓 Бесплатный"
    
    await msg.answer(
        f"Привет, {msg.from_user.first_name}!\n"
        f"Твой статус: {prem}\n"
        f"Компиляций сегодня: {data['daily_count']}/{DAILY_LIMIT if not check_premium(msg.from_user.id) else '∞'}",
        reply_markup=get_main_keyboard(msg.from_user.id)
    )

@dp.message(F.text == "👤 Профиль")
async def profile(msg: Message):
    data = get_user_data(msg.from_user.id)
    prem = "💎 Премиум" if check_premium(msg.from_user.id) else "🆓 Бесплатный"
    
    text = f"👤 <b>Твой профиль</b>\n\nID: <code>{msg.from_user.id}</code>\nСтатус: {prem}\n"
    
    if check_premium(msg.from_user.id):
        if msg.from_user.id == ADMIN_ID:
            text += "Срок действия: <b>Пожизненно (Админ)</b>\n"
        else:
            text += f"Срок действия: <b>до {data['premium_until']}</b>\n"
    else:
        text += f"Компиляций сегодня: {data['daily_count']}/{DAILY_LIMIT}\n\n💡 Купи Премиум за {PREMIUM_PRICE} ⭐, чтобы компилировать без ограничений!"
        
    await msg.answer(text, parse_mode="HTML")

# --- ПОКУПКА ПРЕМИУМА (STARS) ---
@dp.message(F.text == "💎 Купить Премиум")
async def buy_premium(msg: Message):
    if check_premium(msg.from_user.id):
        return await msg.answer("У тебя уже есть Премиум! 😎")
        
    await bot.send_invoice(
        chat_id=msg.chat.id,
        title="Премиум-подписка",
        description="Безлимитная компиляция модов на 30 дней",
        payload="premium_30d",
        provider_token="",
        currency="XTR",
        prices=[LabeledPrice(label="Премиум на 30 дней", amount=PREMIUM_PRICE)]
    )

@dp.pre_checkout_query()
async def pre_checkout(query: PreCheckoutQuery):
    await bot.answer_pre_checkout_query(query.id, ok=True)

@dp.message(F.successful_payment)
async def on_payment(msg: Message):
    if msg.successful_payment.invoice_payload == "premium_30d":
        set_premium(msg.from_user.id, 30)
        await msg.answer("✅ Оплата прошла! Теперь у тебя Премиум на 30 дней. Компилируй без ограничений! 🚀")

# --- ПРОМОКОДЫ (ВВОД) ---
@dp.message(F.text == "🎁 Ввести промокод")
async def enter_promo(msg: Message, state: FSMContext):
    await msg.answer("Введи промокод (например, <code>VIP2026</code>):", parse_mode="HTML")
    await state.set_state(PromoState.waiting_for_name) # Используем это состояние для ввода

@dp.message(PromoState.waiting_for_name)
async def check_promo(msg: Message, state: FSMContext):
    code = msg.text.strip().upper()
    user_id = msg.from_user.id
    
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("SELECT days, used_by FROM promocodes WHERE code = ?", (code,))
    row = c.fetchone()
    
    if not row:
        conn.close()
        await msg.answer("❌ Такого промокода не существует.")
        await state.clear()
        return
        
    days, used_by = row
    used_list = used_by.split(",") if used_by else []
    
    if str(user_id) in used_list:
        conn.close()
        await msg.answer("❌ Ты уже активировал этот промокод.")
        await state.clear()
        return
        
    # Активируем промокод
    if days == -1:
        # Пожизненный (ставим 9999 дней)
        set_premium(user_id, 9999)
        await msg.answer("🎉 Промокод активирован! Ты получил <b>Пожизненный Премиум</b>!", parse_mode="HTML")
    else:
        set_premium(user_id, days)
        await msg.answer(f"🎉 Промокод активирован! Ты получил <b>Премиум на {days} дн.</b>", parse_mode="HTML")
        
    used_list.append(str(user_id))
    new_used = ",".join(used_list)
    c.execute("UPDATE promocodes SET used_by = ? WHERE code = ?", (new_used, code))
    conn.commit()
    conn.close()
    await state.clear()

# --- СОЗДАНИЕ ПРОМОКОДОВ (ТОЛЬКО АДМИН) ---
@dp.message(F.text == "🛠 Создать промокод")
async def create_promo_start(msg: Message, state: FSMContext):
    if msg.from_user.id != ADMIN_ID:
        return await msg.answer("⛔ У тебя нет прав.")
    await msg.answer("Введи название промокода (латиницей, без пробелов):")
    await state.set_state(PromoState.waiting_for_name)

@dp.message(PromoState.waiting_for_name)
async def create_promo_name(msg: Message, state: FSMContext):
    # Если это админ, и он вводит название промокода
    if msg.from_user.id == ADMIN_ID and not msg.text.startswith("/"):
        # Проверяем, не ввел ли он промокод случайно
        conn = sqlite3.connect("users.db")
        c = conn.cursor()
        c.execute("SELECT code FROM promocodes WHERE code = ?", (msg.text.upper(),))
        if c.fetchone():
            conn.close()
            return await msg.answer("Такой промокод уже существует. Введи другой.")
        conn.close()
        
        await state.update_data(promo_name=msg.text.upper())
        await msg.answer("Сколько дней премиума он даёт? (Напиши число, или <code>-1</code> для пожизненного):", parse_mode="HTML")
        await state.set_state(PromoState.waiting_for_days)
    else:
        # Если это не админ или ошибка, обрабатываем как ввод промокода
        await check_promo(msg, state)

@dp.message(PromoState.waiting_for_days)
async def create_promo_days(msg: Message, state: FSMContext):
    if msg.from_user.id != ADMIN_ID:
        return await msg.answer("⛔ У тебя нет прав.")
        
    try:
        days = int(msg.text.strip())
    except ValueError:
        return await msg.answer("Введи число (например, 1, 30, 365, или -1).")
        
    data = await state.get_data()
    code = data.get("promo_name")
    
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("INSERT INTO promocodes (code, days, used_by) VALUES (?, ?, '')", (code, days))
    conn.commit()
    conn.close()
    
    if days == -1:
        await msg.answer(f"✅ Промокод <code>{code}</code> создан! Он дает <b>Пожизненный Премиум</b>.", parse_mode="HTML")
    else:
        await msg.answer(f"✅ Промокод <code>{code}</code> создан! Он дает <b>Премиум на {days} дн.</b>", parse_mode="HTML")
        
    await state.clear()

@dp.message(F.text == "❓ Помощь")
async def help_msg(msg: Message):
    await msg.answer("1. Скинь ZIP-архив с модом.\n2. Забери готовый .amx.\n\nБесплатно дается 3 компиляции в день.")

@dp.message(F.text == "📂 Отправить мод ZIP")
async def send_zip_msg(msg: Message):
    await msg.answer("Жду твой ZIP-архив! 📦")

# --- ПРОГРЕСС-БАР ---
async def animate_progress(message: Message, stop_event: asyncio.Event):
    for i in range(1, 101, 20):
        if stop_event.is_set(): break
        filled = int(i / 20)
        empty = 5 - filled
        bar = "🟩" * filled + "⬜" * empty
        try:
            await message.edit_text(f"⏳ <b>Обработка...</b>\n[{bar}] {i}%", parse_mode="HTML")
        except: pass
        await asyncio.sleep(1)

# --- КОМПИЛЯЦИЯ ---
@dp.message(F.document)
async def handle_zip(msg: Message):
    user_id = msg.from_user.id
    
    if not check_premium(user_id):
        data = get_user_data(user_id)
        if data["daily_count"] >= DAILY_LIMIT:
            return await msg.answer(f"⛔ Лимит исчерпан ({DAILY_LIMIT}/{DAILY_LIMIT}).\n\nКупи Премиум за {PREMIUM_PRICE} ⭐, чтобы компилировать без ограничений!", reply_markup=get_main_keyboard(user_id))
    
    if not msg.document.file_name.endswith(".zip"):
        return await msg.answer("Нужен именно ZIP-архив!")
    
    progress_msg = await msg.answer("⏳ <b>Начинаю обработку...</b>", parse_mode="HTML")
    stop_event = asyncio.Event()
    progress_task = asyncio.create_task(animate_progress(progress_msg, stop_event))
    
    try:
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
        stop_event.set()
        await progress_task
        await progress_msg.edit_text("🚀 <b>Файлы загружены! Жду компилятор...</b>", parse_mode="HTML")
    
    wf_url = f"https://api.github.com/repos/{REPO}/actions/workflows/compile.yml/dispatches"
    requests.post(wf_url, headers=gh_headers, json={"ref": "main", "inputs": {"request_id": request_id, "source_dir": temp_dir}})
    
    if not check_premium(user_id):
        update_user_count(user_id)
    
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
                
                if not check_premium(user_id):
                    data = get_user_data(user_id)
                    await msg.answer_document(FSInputFile(f"temp_out/{amx_file}"), caption=f"✅ Успешно!\nОсталось компиляций: {DAILY_LIMIT - data['daily_count']}")
                else:
                    await msg.answer_document(FSInputFile(f"temp_out/{amx_file}"), caption="✅ Успешно скомпилировано! (Премиум)")
                
                os.remove(f"temp_out/{amx_file}")
                os.rmdir("temp_out")
                return
            else:
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
                return
    
    await msg.answer("⌛ GitHub слишком долго думает. Попробуй позже.")

async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
