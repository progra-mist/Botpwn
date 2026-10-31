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
from aiogram.types import (
    Message, FSInputFile, ReplyKeyboardMarkup, KeyboardButton,
    InlineKeyboardMarkup, InlineKeyboardButton, LabeledPrice, PreCheckoutQuery, CallbackQuery
)
from aiogram.filters import CommandStart
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
OWNER_ID = 8827502259
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
    waiting_for_admin = State()
    waiting_for_revoke = State()
    waiting_for_broadcast = State()
    waiting_for_promo_name = State()
    waiting_for_promo_days = State()
    waiting_for_promo_limit = State()
    waiting_for_activation = State()
    waiting_for_revoke_vip = State()
    waiting_for_delete_promo = State()

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
    c.execute('''CREATE TABLE IF NOT EXISTS users
                 (user_id INTEGER PRIMARY KEY, 
                  username TEXT,
                  premium_until TEXT,
                  daily_count INTEGER,
                  last_date TEXT,
                  is_admin INTEGER DEFAULT 0,
                  last_active TEXT)''')
    c.execute('''CREATE TABLE IF NOT EXISTS promocodes
                 (code TEXT PRIMARY KEY, 
                  days INTEGER, 
                  max_uses INTEGER,
                  used_by TEXT)''')
    try:
        c.execute("ALTER TABLE users ADD COLUMN is_admin INTEGER DEFAULT 0")
    except: pass
    try:
        c.execute("ALTER TABLE users ADD COLUMN last_active TEXT")
    except: pass
    conn.commit()
    conn.close()
    upload_db()

def update_username(user_id, username):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    c.execute("INSERT INTO users (user_id, username, daily_count, last_date, last_active) VALUES (?, ?, 0, ?, ?) ON CONFLICT(user_id) DO UPDATE SET username = ?, last_active = ?", 
              (user_id, username, datetime.now().strftime("%Y-%m-%d"), now, username, now))
    conn.commit()
    conn.close()
    upload_db()

def get_user_data(user_id):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("SELECT premium_until, daily_count, last_date, is_admin, last_active FROM users WHERE user_id = ?", (user_id,))
    row = c.fetchone()
    today = datetime.now().strftime("%Y-%m-%d")
    if not row:
        c.execute("INSERT INTO users (user_id, daily_count, last_date) VALUES (?, 0, ?)", (user_id, today))
        conn.commit()
        conn.close()
        upload_db()
        return {"premium_until": None, "daily_count": 0, "is_admin": 0, "last_active": None}
    premium_until, daily_count, last_date, is_admin, last_active = row
    if last_date != today:
        c.execute("UPDATE users SET daily_count = 0, last_date = ? WHERE user_id = ?", (today, user_id))
        conn.commit()
        daily_count = 0
    conn.close()
    return {"premium_until": premium_until, "daily_count": daily_count, "is_admin": is_admin, "last_active": last_active}

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

def revoke_vip(user_id):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("UPDATE users SET premium_until = NULL WHERE user_id = ?", (user_id,))
    conn.commit()
    conn.close()
    upload_db()

def set_admin(user_id, is_admin):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("UPDATE users SET is_admin = ? WHERE user_id = ?", (is_admin, user_id))
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
    if user_id == OWNER_ID: return True 
    data = get_user_data(user_id)
    if data["premium_until"]:
        premium_date = datetime.strptime(data["premium_until"], "%Y-%m-%d %H:%M:%S")
        if premium_date > datetime.now(): return True
    return False

def is_admin(user_id):
    if user_id == OWNER_ID: return True
    data = get_user_data(user_id)
    return data["is_admin"] == 1

def get_recent_users(limit=10):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("SELECT user_id, username, last_active, is_admin FROM users ORDER BY last_active DESC LIMIT ?", (limit,))
    rows = c.fetchall()
    conn.close()
    return rows

def get_all_promocodes():
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("SELECT code, days, max_uses, used_by FROM promocodes")
    rows = c.fetchall()
    conn.close()
    return rows

def delete_promo(code):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("DELETE FROM promocodes WHERE code = ?", (code,))
    conn.commit()
    conn.close()
    upload_db()

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
    if is_admin(user_id):
        kb.insert(3, [KeyboardButton(text="🛠 Админ-панель")])
    return ReplyKeyboardMarkup(keyboard=kb, resize_keyboard=True)

def get_admin_inline_keyboard():
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="📊 Статистика", callback_data="admin_stats")],
        [InlineKeyboardButton(text="📢 Рассылка", callback_data="admin_broadcast")],
        [InlineKeyboardButton(text="🎁 Выдать VIP", callback_data="admin_give_vip")],
        [InlineKeyboardButton(text="❌ Забрать VIP", callback_data="admin_revoke_vip")],
        [InlineKeyboardButton(text="➕ Выдать компиляции", callback_data="admin_give_compiles")],
        [InlineKeyboardButton(text="🛠 Создать промокод", callback_data="admin_create_promo")],
        [InlineKeyboardButton(text="🗑 Удалить промокод", callback_data="admin_delete_promo")],
        [InlineKeyboardButton(text="👥 Пользователи", callback_data="admin_users")],
        [InlineKeyboardButton(text="👑 Выдать админа", callback_data="admin_give_admin")],
        [InlineKeyboardButton(text="🔙 Назад", callback_data="admin_back")]
    ])

@dp.message(CommandStart())
async def start(msg: Message):
    init_db()
    if msg.from_user.username:
        update_username(msg.from_user.id, msg.from_user.username)
    data = get_user_data(msg.from_user.id)
    prem = "💎 Премиум" if check_premium(msg.from_user.id) else "🆓 Бесплатный"
    await msg.answer(
        f"Привет, {msg.from_user.first_name}!\nТвой статус: {prem}\nКомпиляций сегодня: {data['daily_count']}/{DAILY_LIMIT if not check_premium(msg.from_user.id) else '∞'}",
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
        if msg.from_user.id == OWNER_ID:
            text += "Срок действия: <b>Пожизненно (Владелец)</b>\n"
        else:
            text += f"Срок действия: <b>до {data['premium_until']}</b>\n"
    else:
        text += f"Компиляций сегодня: {data['daily_count']}/{DAILY_LIMIT}\n\n💡 Купи Премиум за {PREMIUM_PRICE} ⭐!"
    if is_admin(msg.from_user.id):
        text += "\n👑 <b>Ты администратор!</b>"
    await msg.answer(text, parse_mode="HTML")

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
        await msg.answer("✅ Оплата прошла! Теперь у тебя Премиум на 30 дней! 🚀")

# --- АДМИН-ПАНЕЛЬ ---
@dp.message(F.text == "🛠 Админ-панель")
async def admin_panel(msg: Message):
    if not is_admin(msg.from_user.id):
        return await msg.answer("⛔ У тебя нет прав.")
    await msg.answer("👑 <b>Админ-панель</b>\nВыбери действие:", 
                     reply_markup=get_admin_inline_keyboard(), parse_mode="HTML")

@dp.callback_query(F.data == "admin_back")
async def admin_back(callback: CallbackQuery):
    await callback.message.delete()
    await callback.answer()

@dp.callback_query(F.data == "admin_stats")
async def admin_stats(callback: CallbackQuery):
    if not is_admin(callback.from_user.id): return
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("SELECT COUNT(*) FROM users")
    total = c.fetchone()[0]
    c.execute("SELECT COUNT(*) FROM users WHERE premium_until > ?", (datetime.now().strftime("%Y-%m-%d %H:%M:%S"),))
    prem = c.fetchone()[0]
    c.execute("SELECT COUNT(*) FROM users WHERE is_admin = 1")
    admins = c.fetchone()[0]
    c.execute("SELECT SUM(daily_count) FROM users WHERE last_date = ?", (datetime.now().strftime("%Y-%m-%d"),))
    comps = c.fetchone()[0] or 0
    conn.close()
    await callback.message.answer(f"📊 <b>Статистика:</b>\n\n👥 Всего пользователей: {total}\n💎 Премиум: {prem}\n👑 Админов: {admins}\n⚙️ Компиляций сегодня: {comps}", parse_mode="HTML")
    await callback.answer()

@dp.callback_query(F.data == "admin_broadcast")
async def admin_broadcast_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id): return
    await callback.message.answer("Введи текст для рассылки:")
    await state.set_state(AdminState.waiting_for_broadcast)
    await callback.answer()

@dp.message(AdminState.waiting_for_broadcast)
async def process_broadcast(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id): return
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("SELECT user_id FROM users")
    users = c.fetchall()
    conn.close()
    count = 0
    for user in users:
        try:
            await bot.send_message(user[0], msg.text)
            count += 1
        except: pass
    await msg.answer(f"✅ Рассылка завершена. Отправлено: {count} пользователям.")
    await state.clear()

# --- ВЫДАТЬ / ЗАБРАТЬ VIP ---
@dp.callback_query(F.data == "admin_give_vip")
async def admin_give_vip_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id): return
    await callback.message.answer("Введи <b>@юзернейм</b> (или ID) и количество дней через пробел:", parse_mode="HTML")
    await state.set_state(AdminState.waiting_for_vip)
    await callback.answer()

@dp.message(AdminState.waiting_for_vip)
async def process_give_vip(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id): return
    try:
        target, days_str = msg.text.split()
        days = int(days_str)
        if target.startswith("@"):
            target_id = find_user_by_username(target)
            if not target_id: return await msg.answer("❌ Пользователь не найден.")
        else:
            target_id = int(target)
        set_premium(target_id, days)
        await msg.answer(f"✅ Пользователю <code>{target}</code> выдан VIP на {days} дней!", parse_mode="HTML")
    except:
        await msg.answer("❌ Ошибка. Пиши: @юзернейм (или ID) и дни.")
    await state.clear()

@dp.callback_query(F.data == "admin_revoke_vip")
async def admin_revoke_vip_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id): return
    await callback.message.answer("Введи <b>@юзернейм</b> (или ID) пользователя, у которого нужно забрать VIP:", parse_mode="HTML")
    await state.set_state(AdminState.waiting_for_revoke_vip)
    await callback.answer()

@dp.message(AdminState.waiting_for_revoke_vip)
async def process_revoke_vip(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id): return
    target = msg.text.strip()
    if target.startswith("@"):
        target_id = find_user_by_username(target)
        if not target_id: return await msg.answer("❌ Пользователь не найден.")
    else:
        target_id = int(target)
    revoke_vip(target_id)
    await msg.answer(f"✅ У пользователя <code>{target}</code> забран VIP.", parse_mode="HTML")
    await state.clear()

# --- ВЫДАТЬ КОМПИЛЯЦИИ ---
@dp.callback_query(F.data == "admin_give_compiles")
async def admin_give_compiles_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id): return
    await callback.message.answer("Введи <b>@юзернейм</b> (или ID) и количество компиляций через пробел:", parse_mode="HTML")
    await state.set_state(AdminState.waiting_for_compiles)
    await callback.answer()

@dp.message(AdminState.waiting_for_compiles)
async def process_give_compiles(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id): return
    try:
        target, count_str = msg.text.split()
        count = int(count_str)
        if target.startswith("@"):
            target_id = find_user_by_username(target)
            if not target_id: return await msg.answer("❌ Пользователь не найден.")
        else:
            target_id = int(target)
        conn = sqlite3.connect("users.db")
        c = conn.cursor()
        c.execute("UPDATE users SET daily_count = daily_count - ? WHERE user_id = ?", (count, target_id))
        conn.commit()
        conn.close()
        upload_db()
        await msg.answer(f"✅ Пользователю <code>{target}</code> добавлено {count} компиляций!", parse_mode="HTML")
    except:
        await msg.answer("❌ Ошибка. Пиши: @юзернейм (или ID) и количество.")
    await state.clear()

# --- ПРОМОКОДЫ (СОЗДАНИЕ, УДАЛЕНИЕ, ВВОД) ---
@dp.callback_query(F.data == "admin_create_promo")
async def admin_create_promo_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id): return
    await callback.message.answer("Введи название промокода:")
    await state.set_state(AdminState.waiting_for_promo_name)
    await callback.answer()

@dp.message(AdminState.waiting_for_promo_name)
async def process_promo_name(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id): return
    code = msg.text.strip().upper()
    await state.update_data(promo_name=code)
    await msg.answer("Сколько дней премиума он даёт? (-1 для пожизненного):")
    await state.set_state(AdminState.waiting_for_promo_days)

@dp.message(AdminState.waiting_for_promo_days)
async def process_promo_days(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id): return
    try: days = int(msg.text.strip())
    except: return await msg.answer("Введи число (1, 30, -1).")
    await state.update_data(promo_days=days)
    await msg.answer("Сколько раз можно активировать? (1-99999):")
    await state.set_state(AdminState.waiting_for_promo_limit)

@dp.message(AdminState.waiting_for_promo_limit)
async def process_promo_limit(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id): return
    try:
        limit = int(msg.text.strip())
        if limit < 1 or limit > 99999: raise ValueError
    except: return await msg.answer("Введи число от 1 до 99999.")
    data = await state.get_data()
    code = data.get("promo_name")
    days = data.get("promo_days")
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("INSERT INTO promocodes (code, days, max_uses, used_by) VALUES (?, ?, ?, '')", (code, days, limit))
    conn.commit()
    conn.close()
    upload_db()
    await msg.answer(f"✅ Промокод <code>{code}</code> создан! ({days} дн., лимит: {limit if limit < 99999 else '∞'}).", parse_mode="HTML")
    await state.clear()

@dp.callback_query(F.data == "admin_delete_promo")
async def admin_delete_promo_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id): return
    promos = get_all_promocodes()
    if not promos:
        return await callback.message.answer("Нет созданных промокодов.")
    text = "Введи название промокода для удаления:\n\n"
    for p in promos:
        used = len(p[3].split(",")) if p[3] else 0
        text += f"• <code>{p[0]}</code> ({p[1]} дн., {used}/{p[2]})\n"
    await callback.message.answer(text, parse_mode="HTML")
    await state.set_state(AdminState.waiting_for_delete_promo)
    await callback.answer()

@dp.message(AdminState.waiting_for_delete_promo)
async def process_delete_promo(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id): return
    code = msg.text.strip().upper()
    delete_promo(code)
    await msg.answer(f"✅ Промокод <code>{code}</code> удалён.", parse_mode="HTML")
    await state.clear()

@dp.message(F.text == "🎁 Ввести промокод")
async def enter_promo(msg: Message, state: FSMContext):
    await msg.answer("Введи промокод:")
    await state.set_state(AdminState.waiting_for_activation)

@dp.message(AdminState.waiting_for_activatio
