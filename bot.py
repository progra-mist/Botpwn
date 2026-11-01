import os, time, requests, zipfile, io, base64, asyncio, sqlite3, uuid
from datetime import datetime, timedelta
from aiogram import Bot, Dispatcher, F
from aiogram.types import Message, FSInputFile, ReplyKeyboardMarkup, KeyboardButton, InlineKeyboardMarkup, InlineKeyboardButton, LabeledPrice, PreCheckoutQuery, CallbackQuery
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
gh_headers = {"Authorization": f"Bearer {GITHUB_TOKEN}", "Accept": "application/vnd.github+json"}


class AdminState(StatesGroup):
    waiting_for_vip = State()
    waiting_for_compiles = State()
    waiting_for_admin = State()
    waiting_for_broadcast = State()
    waiting_for_promo_name = State()
    waiting_for_promo_days = State()
    waiting_for_promo_limit = State()
    waiting_for_activation = State()
    waiting_for_revoke_vip = State()
    waiting_for_delete_promo = State()


def download_db():
    url = f"https://api.github.com/repos/{REPO}/contents/users.db"
    resp = requests.get(url, headers=gh_headers)
    if resp.status_code == 200:
        with open("users.db", "wb") as f:
            f.write(base64.b64decode(resp.json()["content"]))


def upload_db():
    url = f"https://api.github.com/repos/{REPO}/contents/users.db"
    resp = requests.get(url, headers=gh_headers)
    sha = resp.json().get("sha") if resp.status_code == 200 else None
    with open("users.db", "rb") as f:
        content = base64.b64encode(f.read()).decode()
    data = {"message": "Update db", "content": content}
    if sha:
        data["sha"] = sha
    requests.put(url, headers=gh_headers, json=data)


def init_db():
    download_db()
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("CREATE TABLE IF NOT EXISTS users (user_id INTEGER PRIMARY KEY, username TEXT, premium_until TEXT, daily_count INTEGER, last_date TEXT, is_admin INTEGER DEFAULT 0, last_active TEXT)")
    c.execute("CREATE TABLE IF NOT EXISTS promocodes (code TEXT PRIMARY KEY, days INTEGER, max_uses INTEGER, used_by TEXT)")
    try:
        c.execute("ALTER TABLE users ADD COLUMN is_admin INTEGER DEFAULT 0")
    except:
        pass
    try:
        c.execute("ALTER TABLE users ADD COLUMN last_active TEXT")
    except:
        pass
    conn.commit()
    conn.close()
    upload_db()


def update_username(user_id, username):
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    c.execute(
        "INSERT INTO users (user_id, username, daily_count, last_date, last_active) VALUES (?, ?, 0, ?, ?) ON CONFLICT(user_id) DO UPDATE SET username = ?, last_active = ?",
        (user_id, username, datetime.now().strftime("%Y-%m-%d"), now, username, now)
    )
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
        return {"premium_until": None, "daily_count": 0, "last_date": today, "is_admin": 0, "last_active": None}
    premium_until, daily_count, last_date, is_admin, last_active = row
    if last_date != today:
        c.execute("UPDATE users SET daily_count = 0, last_date = ? WHERE user_id = ?", (today, user_id))
        conn.commit()
        daily_count = 0
    conn.close()
    return {"premium_until": premium_until, "daily_count": daily_count, "last_date": today, "is_admin": is_admin, "last_active": last_active}


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
        premium_until = (current_premium + timedelta(days=days)).strftime("%Y-%m-%d %H:%M:%S") if current_premium > datetime.now() else (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d %H:%M:%S")
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


def resolve_target(target: str):
    """Возвращает user_id по '@username', 'username' или числовому ID. None если не найден."""
    if not target:
        return None
    target = target.strip()
    if target.startswith("@"):
        return find_user_by_username(target)
    if target.isdigit():
        return int(target)
    return find_user_by_username(target)


def check_premium(user_id):
    if user_id == OWNER_ID:
        return True
    data = get_user_data(user_id)
    if data["premium_until"]:
        if datetime.strptime(data["premium_until"], "%Y-%m-%d %H:%M:%S") > datetime.now():
            return True
    return False


def is_admin(user_id):
    if user_id == OWNER_ID:
        return True
    return get_user_data(user_id)["is_admin"] == 1


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


def get_main_keyboard(user_id):
    kb = [
        [KeyboardButton(text="🚀 Начать")],
        [KeyboardButton(text="👤 Профиль")],
        [KeyboardButton(text="💎 Купить Премиум")],
        [KeyboardButton(text="🎁 Ввести промокод")],
        [KeyboardButton(text="📂 Отправить мод ZIP")],
        [KeyboardButton(text="❓ Помощь")],
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
        [InlineKeyboardButton(text="🔙 Назад", callback_data="admin_back")],
    ])


@dp.message(CommandStart())
async def start(msg: Message):
    init_db()
    if msg.from_user.username:
        update_username(msg.from_user.id, msg.from_user.username)
    data = get_user_data(msg.from_user.id)
    prem = "💎 Премиум" if check_premium(msg.from_user.id) else "🆓 Бесплатный"
    await msg.answer(
        f"Привет, {msg.from_user.first_name}!\nСтатус: {prem}\nКомпиляций: {data['daily_count']}/{DAILY_LIMIT if not check_premium(msg.from_user.id) else '∞'}",
        reply_markup=get_main_keyboard(msg.from_user.id)
    )


@dp.message(F.text == "🚀 Начать")
async def start_btn(msg: Message):
    await start(msg)


@dp.message(F.text == "👤 Профиль")
async def profile(msg: Message):
    data = get_user_data(msg.from_user.id)
    prem = "💎 Премиум" if check_premium(msg.from_user.id) else "🆓 Бесплатный"
    text = f"👤 <b>Профиль</b>\nID: {msg.from_user.id}\nСтатус: {prem}\n"
    if check_premium(msg.from_user.id):
        if msg.from_user.id == OWNER_ID:
            text += "Срок: Пожизненно (Владелец)\n"
        else:
            text += f"Срок: до {data['premium_until']}\n"
    else:
        text += f"Компиляций: {data['daily_count']}/{DAILY_LIMIT}\n\n💡 Купи Премиум за {PREMIUM_PRICE} ⭐!"
    if is_admin(msg.from_user.id):
        text += "\n👑 Ты админ!"
    await msg.answer(text, parse_mode="HTML")


@dp.message(F.text == "💎 Купить Премиум")
async def buy_premium(msg: Message):
    if check_premium(msg.from_user.id):
        return await msg.answer("У тебя уже есть Премиум! 😎")
    await bot.send_invoice(
        chat_id=msg.chat.id,
        title="Премиум",
        description="Безлимит на 30 дней",
        payload="premium_30d",
        provider_token="",
        currency="XTR",
        prices=[LabeledPrice(label="30 дней", amount=PREMIUM_PRICE)]
    )


@dp.pre_checkout_query()
async def pre_checkout(query: PreCheckoutQuery):
    await bot.answer_pre_checkout_query(query.id, ok=True)


@dp.message(F.successful_payment)
async def on_payment(msg: Message):
    if msg.successful_payment.invoice_payload == "premium_30d":
        set_premium(msg.from_user.id, 30)
        await msg.answer("✅ Оплата прошла! Теперь у тебя Премиум на 30 дней! 🚀")


@dp.message(F.text == "🛠 Админ-панель")
async def admin_panel(msg: Message):
    if not is_admin(msg.from_user.id):
        return await msg.answer("⛔ Нет прав.")
    await msg.answer("👑 <b>Админ-панель</b>", reply_markup=get_admin_inline_keyboard(), parse_mode="HTML")


@dp.callback_query(F.data == "admin_back")
async def admin_back(callback: CallbackQuery):
    await callback.message.delete()
    await callback.answer()


@dp.callback_query(F.data == "admin_stats")
async def admin_stats(callback: CallbackQuery):
    if not is_admin(callback.from_user.id):
        return
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
    await callback.message.answer(f"📊 <b>Статистика:</b>\n👥 Юзеров: {total}\n💎 Премиум: {prem}\n👑 Админов: {admins}\n⚙️ Компиляций: {comps}", parse_mode="HTML")
    await callback.answer()


@dp.callback_query(F.data == "admin_broadcast")
async def admin_broadcast_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id):
        return
    await callback.message.answer("Текст для рассылки:")
    await state.set_state(AdminState.waiting_for_broadcast)
    await callback.answer()


@dp.message(AdminState.waiting_for_broadcast)
async def process_broadcast(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id):
        return
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
        except Exception:
            pass
        await asyncio.sleep(0.05)
    await msg.answer(f"✅ Отправлено: {count}")
    await state.clear()


@dp.callback_query(F.data == "admin_give_vip")
async def admin_give_vip_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id):
        return
    await callback.message.answer("Введи @юзернейм и дни (или ID и дни):")
    await state.set_state(AdminState.waiting_for_vip)
    await callback.answer()


@dp.message(AdminState.waiting_for_vip)
async def process_give_vip(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id):
        return
    st = await state.get_data()
    target_uid = st.get("target_uid")
    try:
        if target_uid:
            days = int(msg.text.strip())
            set_premium(target_uid, days)
            await msg.answer(f"✅ Выдан VIP на {days} дн.")
        else:
            target, days_str = msg.text.split()
            days = int(days_str)
            target_id = resolve_target(target)
            if not target_id:
                return await msg.answer("❌ Не найден.")
            set_premium(target_id, days)
            await msg.answer(f"✅ Выдан VIP на {days} дн.")
    except Exception as e:
        await msg.answer(f"❌ Ошибка: {e}")
    await state.clear()


@dp.callback_query(F.data == "admin_revoke_vip")
async def admin_revoke_vip_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id):
        return
    await callback.message.answer("Введи @юзернейм (или ID):")
    await state.set_state(AdminState.waiting_for_revoke_vip)
    await callback.answer()


@dp.message(AdminState.waiting_for_revoke_vip)
async def process_revoke_vip(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id):
        return
    target_id = resolve_target(msg.text.strip())
    if not target_id:
        return await msg.answer("❌ Не найден.")
    revoke_vip(target_id)
    await msg.answer("✅ VIP забран.")
    await state.clear()


@dp.callback_query(F.data == "admin_give_compiles")
async def admin_give_compiles_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id):
        return
    await callback.message.answer("Введи @юзернейм и кол-во:")
    await state.set_state(AdminState.waiting_for_compiles)
    await callback.answer()


@dp.message(AdminState.waiting_for_compiles)
async def process_give_compiles(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id):
        return
    st = await state.get_data()
    target_uid = st.get("target_uid")
    try:
        if target_uid:
            count = int(msg.text.strip())
            target_id = target_uid
        else:
            target, count_str = msg.text.split()
            target_id = resolve_target(target)
            count = int(count_str)
        if not target_id:
            return await msg.answer("❌ Не найден.")
        conn = sqlite3.connect("users.db")
        c = conn.cursor()
        c.execute("UPDATE users SET daily_count = daily_count + ? WHERE user_id = ?", (count, target_id))
        conn.commit()
        conn.close()
        upload_db()
        await msg.answer(f"✅ +{count} компиляций.")
    except Exception as e:
        await msg.answer(f"❌ Ошибка: {e}")
    await state.clear()


@dp.callback_query(F.data == "admin_create_promo")
async def admin_create_promo_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id):
        return
    await callback.message.answer("Название промокода:")
    await state.set_state(AdminState.waiting_for_promo_name)
    await callback.answer()


@dp.message(AdminState.waiting_for_promo_name)
async def process_promo_name(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id):
        return
    await state.update_data(promo_name=msg.text.strip().upper())
    await msg.answer("Дней (-1 = навсегда):")
    await state.set_state(AdminState.waiting_for_promo_days)


@dp.message(AdminState.waiting_for_promo_days)
async def process_promo_days(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id):
        return
    try:
        days = int(msg.text.strip())
    except:
        return await msg.answer("Число.")
    await state.update_data(promo_days=days)
    await msg.answer("Лимит (1-99999):")
    await state.set_state(AdminState.waiting_for_promo_limit)


@dp.message(AdminState.waiting_for_promo_limit)
async def process_promo_limit(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id):
        return
    try:
        limit = int(msg.text.strip())
        if limit < 1 or limit > 99999:
            raise ValueError
    except:
        return await msg.answer("1-99999.")
    data = await state.get_data()
    code = data.get("promo_name")
    days = data.get("promo_days")
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("INSERT INTO promocodes (code, days, max_uses, used_by) VALUES (?, ?, ?, '')", (code, days, limit))
    conn.commit()
    conn.close()
    upload_db()
    await msg.answer(f"✅ Промокод {code} создан.")
    await state.clear()


@dp.callback_query(F.data == "admin_delete_promo")
async def admin_delete_promo_start(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id):
        return
    promos = get_all_promocodes()
    if not promos:
        return await callback.message.answer("Нет промокодов.")
    await callback.message.answer("Код для удаления:\n" + "\n".join([f"• {p[0]}" for p in promos]))
    await state.set_state(AdminState.waiting_for_delete_promo)
    await callback.answer()


@dp.message(AdminState.waiting_for_delete_promo)
async def process_delete_promo(msg: Message, state: FSMContext):
    if not is_admin(msg.from_user.id):
        return
    delete_promo(msg.text.strip().upper())
    await msg.answer("✅ Удалён.")
    await state.clear()


@dp.message(F.text == "🎁 Ввести промокод")
async def enter_promo(msg: Message, state: FSMContext):
    await msg.answer("Промокод:")
    await state.set_state(AdminState.waiting_for_activation)


@dp.message(AdminState.waiting_for_activation)
async def activate_promo(msg: Message, state: FSMContext):
    code = msg.text.strip().upper()
    user_id = msg.from_user.id
    conn = sqlite3.connect("users.db")
    c = conn.cursor()
    c.execute("SELECT days, max_uses, used_by FROM promocodes WHERE code = ?", (code,))
    row = c.fetchone()
    if not row:
        conn.close()
        await msg.answer("❌ Не существует.")
        await state.clear()
        return
    days, max_uses, used_by = row
    used_list = used_by.split(",") if used_by else []
    if len(used_list) >= max_uses:
        conn.close()
        await msg.answer("❌ Лимит.")
        await state.clear()
        return
    if str(user_id) in used_list:
        conn.close()
        await msg.answer("❌ Уже активирован.")
        await state.clear()
        return
        # Выдача премиума
    if days == -1:
        set_premium(user_id, 9999)
        await msg.answer("🎉 Пожизненный Премиум!")
    else:
        set_premium(user_id, days)
        await msg.answer(f"🎉 Премиум на {days} дн.")

    # Сохранение промокода
    used_list.append(str(user_id))
    new_used = ",".join(used_list)
    c.execute("UPDATE promocodes SET used_by = ? WHERE code = ?", (new_used, code))
    conn.commit()
    conn.close()
    upload_db()
    await state.clear()


@dp.callback_query(F.data == "admin_users")
async def admin_users_list(callback: CallbackQuery):
    if not is_admin(callback.from_user.id):
        return
    users = get_recent_users(10)
    if not users:
        return await callback.message.answer("Пусто.")
    kb = []
    for uid, username, last_active, is_adm in users:
        label = f"{'👑 ' if is_adm else ''}@{username if username else uid}"
        kb.append([InlineKeyboardButton(text=label, callback_data=f"user_info_{uid}")])
    kb.append([InlineKeyboardButton(text="🔙 Назад", callback_data="admin_back")])
    await callback.message.answer("👥 Пользователи:", reply_markup=InlineKeyboardMarkup(inline_keyboard=kb))
    await callback.answer()


@dp.callback_query(F.data.startswith("user_info_"))
async def user_info(callback: CallbackQuery):
    if not is_admin(callback.from_user.id):
        return
    uid = int(callback.data.split("_")[2])
    data = get_user_data(uid)
    prem = "💎 Премиум" if data["premium_until"] and datetime.strptime(data["premium_until"], "%Y-%m-%d %H:%M:%S") > datetime.now() else "🆓 Бесплатный"
    text = f"👤 ID: {uid}\nСтатус: {prem}\n"
    if data["premium_until"]:
        text += f"До: {data['premium_until']}\n"
    if data["is_admin"]:
        text += "👑 Админ\n"
    kb = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🎁 VIP", callback_data=f"user_give_vip_{uid}"), InlineKeyboardButton(text="❌ Снять VIP", callback_data=f"user_revoke_vip_{uid}")],
        [InlineKeyboardButton(text="➕ Компиляции", callback_data=f"user_give_comp_{uid}")],
        [InlineKeyboardButton(text="👑 Админ" if not data["is_admin"] else "❌ Снять админа", callback_data=f"user_toggle_admin_{uid}")],
        [InlineKeyboardButton(text="🔙 Назад", callback_data="admin_users")],
    ])
    await callback.message.edit_text(text, reply_markup=kb)
    await callback.answer()


@dp.callback_query(F.data.startswith("user_give_vip_"))
async def user_give_vip(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id):
        return
    await state.update_data(target_uid=int(callback.data.split("_")[3]))
    await callback.message.answer("Дней:")
    await state.set_state(AdminState.waiting_for_vip)
    await callback.answer()


@dp.callback_query(F.data.startswith("user_revoke_vip_"))
async def user_revoke_vip(callback: CallbackQuery):
    if not is_admin(callback.from_user.id):
        return
    revoke_vip(int(callback.data.split("_")[3]))
    await callback.message.answer("✅ VIP снят.")
    await callback.answer()


@dp.callback_query(F.data.startswith("user_give_comp_"))
async def user_give_comp(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id):
        return
    await state.update_data(target_uid=int(callback.data.split("_")[3]))
    await callback.message.answer("Кол-во:")
    await state.set_state(AdminState.waiting_for_compiles)
    await callback.answer()


@dp.callback_query(F.data.startswith("user_toggle_admin_"))
async def user_toggle_admin(callback: CallbackQuery):
    if not is_admin(callback.from_user.id):
        return
    if callback.from_user.id != OWNER_ID:
        return await callback.answer("⛔ Только Владелец.", show_alert=True)
    uid = int(callback.data.split("_")[3])
    data = get_user_data(uid)
    set_admin(uid, 0 if data["is_admin"] else 1)
    await callback.message.answer("✅ Статус изменен.")
    await callback.answer()


@dp.callback_query(F.data == "admin_give_admin")
async def give_admin_start(callback: CallbackQuery, state: FSMContext):
    if callback.from_user.id != OWNER_ID:
        return await callback.answer("⛔ Только Владелец.", show_alert=True)
    await callback.message.answer("Введи @юзернейм (или ID):")
    await state.set_state(AdminState.waiting_for_admin)
    await callback.answer()


@dp.message(AdminState.waiting_for_admin)
async def process_give_admin(msg: Message, state: FSMContext):
    if msg.from_user.id != OWNER_ID:
        return
    target_id = resolve_target(msg.text.strip())
    if not target_id:
        return await msg.answer("❌ Не найден.")
    set_admin(target_id, 1)
    await msg.answer("✅ Админ выдан.")
    await state.clear()


@dp.message(F.document)
async def handle_zip(msg: Message):
    user_id = msg.from_user.id
    if not check_premium(user_id):
        data = get_user_data(user_id)
        if data["daily_count"] >= DAILY_LIMIT:
            return await msg.answer(f"⛔ Лимит {DAILY_LIMIT}. Купи Премиум за {PREMIUM_PRICE} ⭐!", reply_markup=get_main_keyboard(user_id))
    if not msg.document.file_name.endswith(".zip"):
        return await msg.answer("Нужен ZIP!")
    await msg.answer("⏳ Обработка...")

    request_id = f"{int(time.time())}_{user_id}_{uuid.uuid4().hex[:6]}"
    temp_dir = f"temp_compile/{request_id}"

    buf = io.BytesIO()
    await bot.download(msg.document, destination=buf)
    zip_data = buf.getvalue()

    uploaded_files = []
    try:
        with zipfile.ZipFile(io.BytesIO(zip_data)) as z:
            for file_info in z.infolist():
                if file_info.is_dir():
                    continue
                name = file_info.filename.replace("\\", "/")
                if ".." in name or name.startswith("/"):
                    continue
                if not (name.endswith(".pwn") or name.endswith(".inc") or name.endswith(".lang")):
                    continue
                content = base64.b64encode(z.read(file_info.filename)).decode()
                url = f"https://api.github.com/repos/{REPO}/contents/{temp_dir}/{name}"
                r = requests.put(url, headers=gh_headers, json={"message": "Upload", "content": content})
                if r.status_code in (200, 201):
                    uploaded_files.append(f"{temp_dir}/{name}")
    except zipfile.BadZipFile:
        return await msg.answer("❌ Битый ZIP.")

    if not uploaded_files:
        return await msg.answer("❌ В ZIP нет .pwn/.inc/.lang файлов.")

    await msg.answer("🚀 Компиляция...")
    wf_url = f"https://api.github.com/repos/{REPO}/actions/workflows/compile.yml/dispatches"
    r = requests.post(wf_url, headers=gh_headers, json={"ref": "main", "inputs": {"request_id": request_id, "source_dir": temp_dir}})
    if r.status_code != 204:
        return await msg.answer(f"❌ Не удалось запустить сборку: {r.status_code} {r.text[:200]}")

    if not check_premium(user_id):
        update_user_count(user_id)

    found_run = None
    for _ in range(200):
        await asyncio.sleep(5)
        runs = requests.get(f"https://api.github.com/repos/{REPO}/actions/runs?per_page=20", headers=gh_headers).json()
        for run in runs.get("workflow_runs", []):
            if run["status"] != "completed":
                continue
            title = run.get("display_title") or run.get("name") or ""
            if request_id in title:
                found_run = run
                break
        if found_run:
            break

    # cleanup temp_compile через API
    for path in uploaded_files:
        try:
            get_resp = requests.get(f"https://api.github.com/repos/{REPO}/contents/{path}", headers=gh_headers)
            if get_resp.status_code == 200:
                sha = get_resp.json()["sha"]
                requests.delete(f"https://api.github.com/repos/{REPO}/contents/{path}", headers=gh_headers, json={"message": f"cleanup {request_id}", "sha": sha})
        except Exception:
            pass

    if not found_run:
        return await msg.answer(f"⌛ Долго. (ID: {request_id})")

    run = found_run
    if run["conclusion"] == "success":
        release_tag = f"build-{request_id}"
        release_api = f"https://api.github.com/repos/{REPO}/releases/tags/{release_tag}"
        rel_resp = requests.get(release_api, headers=gh_headers)

        download_url = None
        filename = "Crime.amx"

        if rel_resp.status_code == 200:
            assets = rel_resp.json().get("assets", [])
            if assets:
                download_url = assets[0]["browser_download_url"]
                filename = assets[0]["name"]

        if not download_url:
            download_url = f"https://github.com/{REPO}/releases/download/build-{request_id}/Crime.amx"

        try:
            file_resp = requests.get(download_url, allow_redirects=True, timeout=60)
            if file_resp.status_code == 200:
                if len(file_resp.content) > 50 * 1024 * 1024:
                    await msg.answer(
                        f"✅ Готово, но файл больше 50 МБ.\n📥 <a href='{download_url}'>Скачать {filename}</a>",
                        parse_mode="HTML"
                    )
                else:
                    amx_buf = io.BytesIO(file_resp.content)
                    amx_buf.name = filename
                    await msg.answer_document(
                        FSInputFile(amx_buf, filename=filename),
                        caption="✅ Компиляция успешна!"
                    )
            else:
                await msg.answer(
                    f"✅ Готово, но файл не скачался.\n📥 <a href='{download_url}'>Скачать {filename}</a>",
                    parse_mode="HTML"
                )
        except Exception as e:
            await msg.answer(
                f"✅ Готово, но ошибка скачивания: {e}\n📥 <a href='{download_url}'>Скачать {filename}</a>",
                parse_mode="HTML"
            )
        return
    else:
        logs_url = f"https://api.github.com/repos/{REPO}/actions/runs/{run['id']}/logs"
        log_resp = requests.get(logs_url, headers=gh_headers, allow_redirects=True)
        if log_resp.status_code == 200:
            with zipfile.ZipFile(io.BytesIO(log_resp.content)) as z:
                log_files = [f for f in z.namelist() if "ompile" in f]
                if not log_files:
                    return await msg.answer("❌ Сборка упала, но лог не найден.")
                log_text = z.read(log_files[0]).decode("utf-8", errors="replace")
                log_path = f"error_log_{request_id}.txt"
                with open(log_path, "w", encoding="utf-8") as f:
                    f.write(log_text)
                await msg.answer_document(FSInputFile(log_path), caption=f"❌ Ошибка (run {run['id']}):")
                os.remove(log_path)
        else:
            await msg.answer(f"❌ Сборка упала. Логи: https://github.com/{REPO}/actions/runs/{run['id']}")
        return


@dp.message(F.text == "❓ Помощь")
async def help_msg(msg: Message):
    await msg.answer("1. Скинь ZIP\n2. Забери файл\n\nБесплатно: 3 в день.")


@dp.message(F.text == "📂 Отправить мод ZIP")
async def send_zip_msg(msg: Message):
    await msg.answer("Жду ZIP! 📦")


async def main():
    await dp.start_polling(bot)


if __name__ == "__main__":
    asyncio.run(main())