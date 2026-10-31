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

PREMIUM_PRICE = 5
DAILY_LIMIT = 3

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

gh_headers = {
    "Authorization": f"Bearer {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}

# --- СОСТОЯНИЯ ---
class AdminState(StatesGroup):
    waiting_for_vip = State()
    waiting_for_compiles = State()

class PromoState(StatesGroup):
    waiting_for_name = State()
    waiting_for_days = State()
    waiting_for_limit = State()
    waiting_for_activation = State()

# --- БАЗА ДАННЫХ ---
def download_db():
    url = f"https://api.github.com/repos/{REPO}/contents/users.db"
    resp = requests.get(url, headers=gh_headers)
    if resp.status_code == 200:
        content = base64.b64decode(resp.json()["content"])
        with open("users.db", "wb") as f:
            f.write(content)

def upload_db():
    url = f"https://api.github.com/repos/{REPO}/contents/users.db"
    resp = requests.get(url, headers=gh_headers)
    sha = resp.json().get("sha") if resp.status_code == 200 else None
    
    with open("users.db", "rb") as f:
        content = base64.b64encode(f.read()).decode()
        
    data = {"message": "Update db", "content": content}
    if sha: data["sha"] = sha
    requests.put(url, headers=gh_headers, json=data)

def init_db():
    download_db()
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    
    # Таблица пользователей
    c.execute('''CREATE TABLE IF NOT EXISTS users
                 (user_id INTEGER PRIMARY KEY, 
                  username TEXT,
                  premium_until TEXT,
                  daily_count INTEGER,
                  last_date TEXT)''')
                  
    # Таблица промокодов
    c.execute('''CREATE TABLE IF NOT EXISTS promocodes
                 (code TEXT PRIMARY KEY, 
                  days INTEGER, 
                  used_by TEXT)''')
                  
    # Проверяем, есть ли столбец max_uses, если нет — добавляем
    try:
        c.execute("ALTER TABLE promocodes ADD COLUMN max_uses INTEGER DEFAULT 99999")
    except sqlite3.OperationalError:
        pass # Столбец уже есть
        
    conn.commit()
    conn.close()
    upload_db()

def update_username(user_id, username):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("UPDATE users SET username = ? WHERE user_id = ?", (username, user_id))
    conn.commit()
    conn.close()
    upload_db()

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
        upload_db()
        return {"premium_until": None, "daily_count": 0}
    
    premium_until, daily_count, last_date = row
    if last_date != today:
        c.execute("UPDATE users SET daily_count = 0, last_date = ? WHERE user_id = ?", (today, user_id))
        conn.commit()
        daily_count = 0
        upload_db()
    conn.close()
    return {"premium_until": premium_until, "daily_count": daily_count}

def update_user_count(user_id):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("UPDATE users SET daily_count = daily_count + 1 WHERE user_id = ?", (user_id,))
    conn.commit()
    conn.close()
    upload_db()

def set_premium(user_id, days):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
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
    upload_db()

def find_user_by_username(username):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    username = username.replace("@", "")
    c.execute("SELECT user_id FROM users WHERE username = ?", (username,))
    row = c.fetchone()
    conn.close()
    return row[0] if row else None

def check_premium(user_id):
    if user_id == ADMIN_ID: return True 
    data = get_user_data(user_id)
    if data["premium_until"]:
        premium_date = datetime.strptime(data["premium_until"], "%Y-%m-%d %H:%M:%S")
        if premium_date > datetime.now(): return True
    return False

# --- КНОПКИ ---
def get_main_keyboard(user_id):
    kb = [
        [KeyboardButton(text="🚀 Начать")],
        [KeyboardButton(text="👤 Профиль")],
        [KeyboardButton(text="💎 Купить Премиум")],
        [KeyboardButton(text="🎁 Ввести промокод")],
        [KeyboardButton(text="📂 Отправить мод ZIP")],
        [KeyboardButton(text="❓ Помощь")]
    ]
    if user_id == ADMIN_ID:
        kb.insert(3, [KeyboardButton(text="🎁 Выдать VIP"), KeyboardButton(text="➕ Выдать компиляции")])
        kb.insert(3, [KeyboardButton(text="🛠 Создать промокод")])
    return ReplyKeyboardMarkup(keyboard=kb, resize_keyboard=True)

@dp.message(CommandStart())
async def start(msg: Message):
    init_db()
    if msg.from_user.username:
        update_username(msg.from_user.id, msg.from_user.username)
        
    data = get_user_data(msg.from_user.id)
    prem = "💎 Премиум" if check_premium(msg.from_user.id) else "🆓 Бесплатный"
    
    await msg.answer(
        f"Привет, {msg.from_user.first_name}!\n"
        f"Твой статус: {prem}\n"
        f"Компиляций сегодня: {data['daily_count']}/{DAILY_LIMIT if not check_premium(msg.from_user.id) else '∞'}",
        reply_markup=get_main_keyboard(msg.from_user.id)
    )

@dp.message(F.text == "🚀 Начать")
async def start_btn(msg: Message):
    await start(msg)

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
        text += f"Компиляций сегодня: {data['daily_count']}/{DAILY_LIMIT}\n\n💡 Купи Премиум за {PREMIUM_PRICE} ⭐!"
        
    await msg.answer(text, parse_mode="HTML")

# --- АДМИН: ВЫДАЧА VIP ---
@dp.message(F.text == "🎁 Выдать VIP")
async def admin_give_vip(msg: Message, state: FSMContext):
    if msg.from_user.id != ADMIN_ID: return
    await msg.answer("Введи <b>@юзернейм</b> (или ID) и количество дней через пробел (например: <code>@durov 30</code>):", parse_mode="HTML")
    await state.set_state(AdminState.waiting_for_vip)

@dp.message(AdminState.waiting_for_vip)
async def process_give_vip(msg: Message, state: FSMContext):
    if msg.from_user.id != ADMIN_ID: return
    try:
        target, days_str = msg.text.split()
        days = int(days_str)
        
        if target.startswith("@"):
            target_id = find_user_by_username(target)
            if not target_id:
                await msg.answer("❌ Пользователь с таким юзернеймом не найден в базе. Он должен сначала нажать /start в боте.")
                await state.clear()
                return
        else:
            target_id = int(target)
            
        set_premium(target_id, days)
        await msg.answer(f"✅ Пользователю <code>{target}</code> (ID: {target_id}) выдан VIP на {days} дней!", parse_mode="HTML")
    except:
        await msg.answer("❌ Ошибка. Пиши: @юзернейм (или ID) и дни через пробел.")
    await state.clear()

# --- АДМИН: ВЫДАЧА КОМПИЛЯЦИЙ ---
@dp.message(F.text == "➕ Выдать компиляции")
async def admin_give_compiles(msg: Message, state: FSMContext):
    if msg.from_user.id != ADMIN_ID: return
    await msg.answer("Введи <b>@юзернейм</b> (или ID) и количество компиляций через пробел (например: <code>@durov 10</code>):", parse_mode="HTML")
    await state.set_state(AdminState.waiting_for_compiles)

@dp.message(AdminState.waiting_for_compiles)
async def process_give_compiles(msg: Message, state: FSMContext):
    if msg.from_user.id != ADMIN_ID: return
    try:
        target, count_str = msg.text.split()
        count = int(count_str)
        
        if target.startswith("@"):
            target_id = find_user_by_username(target)
            if not target_id:
                await msg.answer("❌ Пользователь с таким юзернеймом не найден в базе. Он должен сначала нажать /start в боте.")
                await state.clear()
                return
        else:
            target_id = int(target)
            
        conn = sqlite3.connect("users.db")
        c = conn.cursor()
        c.execute("UPDATE users SET daily_count = daily_count - ? WHERE user_id = ?", (count, target_id))
        conn.commit()
        conn.close()
        upload_db()
        
        await msg.answer(f"✅ Пользователю <code>{target}</code> (ID: {target_id}) добавлено {count} компиляций!", parse_mode="HTML")
    except:
        await msg.answer("❌ Ошибка. Пиши: @юзернейм (или ID) и количество через пробел.")
    await state.clear()

# --- ПРОМОКОДЫ (ВВОД) ---
@dp.message(F.text == "🎁 Ввести промокод")
async def enter_promo_user(msg: Message, state: FSMContext):
    await msg.answer("Введи промокод:")
    await state.set_state(PromoState.waiting_for_activation)

@dp.message(PromoState.waiting_for_activation)
async def activate_promo(msg: Message, state: FSMContext):
    code = msg.text.strip().upper()
    user_id = msg.from_user.id
    
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("SELECT days, max_uses, used_by FROM promocodes WHERE code = ?", (code,))
    row = c.fetchone()
    
    if not row:
        conn.close()
        await msg.answer("❌ Такого промокода не существует.")
        await state.clear()
        return
        
    days, max_uses, used_by = row
    used_list = used_by.split(",") if used_by else []
    
    if len(used_list) >= max_uses:
        conn.close()
        await msg.answer("❌ Этот промокод уже использован максимальное количество раз.")
        await state.clear()
        return
        
    if str(user_id) in used_list:
        conn.close()
        await msg.answer("❌ Ты уже активировал этот промокод.")
        await state.clear()
        return
        
    if days == -1:
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
    upload_db()
    await state.clear()

# --- СОЗДАНИЕ ПРОМОКОДА (АДМИН) ---
@dp.message(F.text == "🛠 Создать промокод")
async def create_promo_start(msg: Message, state: FSMContext):
    if msg.from_user.id != ADMIN_ID: return await msg.answer("⛔ У тебя нет прав.")
    await msg.answer("Введи название промокода (например, VIP2026):")
    await state.set_state(PromoState.waiting_for_name)

@dp.message(PromoState.waiting_for_name)
async def create_promo_name(msg: Message, state: FSMContext):
    if msg.from_user.id != ADMIN_ID: return await msg.answer("⛔ Нет прав.")
        
    code = msg.text.strip().upper()
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("SELECT code FROM promocodes WHERE code = ?", (code,))
    if c.fetchone():
        conn.close()
        return await msg.answer("Такой промокод уже есть. Введи другой:")
    conn.close()
    await state.update_data(promo_name=code)
    await msg.answer("Сколько дней премиума он даёт? (Напиши число, или <code>-1</code> для пожизненного):", parse_mode="HTML")
    await state.set_state(PromoState.waiting_for_days)

@dp.message(PromoState.waiting_for_days)
async def create_promo_days(msg: Message, state: FSMContext):
    if msg.from_user.id != ADMIN_ID: return await msg.answer("⛔ Нет прав.")
    try:
        days = int(msg.text.strip())
    except ValueError:
        return await msg.answer("Введи число (1, 30, 365 или -1).")
    
    await state.update_data(promo_days=days)
    await msg.answer("Сколько раз можно активировать промокод? (Введи число от 1 до 99999, где 99999 — бесконечный):")
    await state.set_state(PromoState.waiting_for_limit)

@dp.message(PromoState.waiting_for_limit)
async def create_promo_limit(msg: Message, state: FSMContext):
    if msg.from_user.id != ADMIN_ID: return await msg.answer("⛔ Нет прав.")
    try:
        limit = int(msg.text.strip())
        if limit < 1 or limit > 99999:
            raise ValueError
    except ValueError:
        return await msg.answer("Введи число от 1 до 99999.")
        
    data = await state.get_data()
    code = data.get("promo_name")
    days = data.get("promo_days")
    
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("INSERT INTO promocodes (code, days, max_uses, used_by) VALUES (?, ?, ?, '')", (code, days, limit))
    conn.commit()
    conn.close()
    upload_db()
    
    if days == -1:
        await msg.answer(f"✅ Промокод <code>{code}</code> создан! (Пожизненный, лимит: {limit if limit < 99999 else '∞'}).", parse_mode="HTML")
    else:
        await msg.answer(f"✅ Промокод <code>{code}</code> создан! ({days} дн., лимит: {limit if limit < 99999 else '∞'}).", parse_mode="HTML")
    await state.clear()

@dp.message(F.text == "❓ Помощь")
async def help_msg(msg: Message):
    await msg.answer("1. Скинь ZIP-архив с модом.\n2. Забери готовый .amx.\n\nБесплатно: 3 компиляции в день.")

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
            return await msg.answer(f"⛔ Лимит исчерпан ({DAILY_LIMIT}/{DAILY_LIMIT}).\n\nКупи Премиум за {PREMIUM_PRICE} ⭐!", reply_markup=get_main_keyboard(user_id))
    
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
                    await msg.answer_document(FSInputFile(f"temp_out/{amx_file}"), caption=f"✅ Успешно!\nОсталось: {DAILY_LIMIT - data['daily_count']}")
                else:
                    await msg.answer_document(FSInputFile(f"temp_out/{amx_file}"), caption="✅ Успешно! (Премиум)")
                
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
                        await msg.answer_document(FSInputFile("error_log.txt"), caption="❌ Ошибка компиляции:")
                        os.remove("error_log.txt")
                return

async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
