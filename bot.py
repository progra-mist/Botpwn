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
        await msg.answer("❌ Промокод использован максимальное число раз.")
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

@dp.callback_query(F.data == "admin_users")
async def admin_users_list(callback: CallbackQuery):
    if not is_admin(callback.from_user.id): return
    users = get_recent_users(10)
    if not users:
        return await callback.message.answer("Пользователей пока нет.")
    kb = []
    for u in users:
        uid, username, last_active, is_adm = u
        name = f"@{username}" if username else f"ID:{uid}"
        badge = "👑" if is_adm else ""
        kb.append([InlineKeyboardButton(text=f"{badge} {name} ({last_active or 'не активен'})", callback_data=f"user_info_{uid}")])
    kb.append([InlineKeyboardButton(text="🔙 Назад", callback_data="admin_back")])
    await callback.message.answer("👥 <b>Последние 10 активных пользователей:</b>", reply_markup=InlineKeyboardMarkup(inline_keyboard=kb), parse_mode="HTML")
    await callback.answer()

@dp.callback_query(F.data.startswith("user_info_"))
async def user_info(callback: CallbackQuery):
    if not is_admin(callback.from_user.id): return
    uid = int(callback.data.split("_")[2])
    data = get_user_data(uid)
    prem = "💎 Премиум" if data["premium_until"] and datetime.strptime(data["premium_until"], "%Y-%m-%d %H:%M:%S") > datetime.now() else "🆓 Бесплатный"
    
    text = f"👤 <b>Профиль пользователя</b>\n\nID: <code>{uid}</code>\nСтатус: {prem}\n"
    if data["premium_until"]:
        text += f"VIP до: <b>{data['premium_until']}</b>\n"
    if data["is_admin"]:
        text += "👑 <b>Администратор</b>\n"
    
    kb = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🎁 Выдать VIP", callback_data=f"user_give_vip_{uid}"), InlineKeyboardButton(text="❌ Забрать VIP", callback_data=f"user_revoke_vip_{uid}")],
        [InlineKeyboardButton(text="➕ Выдать компиляции", callback_data=f"user_give_comp_{uid}")],
        [InlineKeyboardButton(text="👑 Выдать админа" if not data["is_admin"] else "❌ Забрать админа", callback_data=f"user_toggle_admin_{uid}")],
        [InlineKeyboardButton(text="🔙 Назад", callback_data="admin_users")]
    ])
    await callback.message.edit_text(text, reply_markup=kb, parse_mode="HTML")
    await callback.answer()

@dp.callback_query(F.data.startswith("user_give_vip_"))
async def user_give_vip(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id): return
    uid = int(callback.data.split("_")[3])
    await state.update_data(target_uid=uid)
    await callback.message.answer("На сколько дней выдать VIP?")
    await state.set_state(AdminState.waiting_for_vip)
    await callback.answer()

@dp.callback_query(F.data.startswith("user_revoke_vip_"))
async def user_revoke_vip(callback: CallbackQuery):
    if not is_admin(callback.from_user.id): return
    uid = int(callback.data.split("_")[3])
    revoke_vip(uid)
    await callback.message.answer(f"✅ У пользователя <code>{uid}</code> забран VIP.", parse_mode="HTML")
    await callback.answer()

@dp.callback_query(F.data.startswith("user_give_comp_"))
async def user_give_comp(callback: CallbackQuery, state: FSMContext):
    if not is_admin(callback.from_user.id): return
    uid = int(callback.data.split("_")[3])
    await state.update_data(target_uid=uid)
    await callback.message.answer("Сколько компиляций выдать?")
    await state.set_state(AdminState.waiting_for_compiles)
    await callback.answer()

@dp.callback_query(F.data.startswith("user_toggle_admin_"))
async def user_toggle_admin(callback: CallbackQuery):
    if not is_admin(callback.from_user.id): return
    if callback.from_user.id != OWNER_ID:
        return await callback.answer("⛔ Только Владелец может менять админов.", show_alert=True)
    uid = int(callback.data.split("_")[3])
    data = get_user_data(uid)
    new_status = 0 if data["is_admin"] else 1
    set_admin(uid, new_status)
    action = "выдан" if new_status else "забран"
    await callback.message.answer(f"✅ Пользователю <code>{uid}</code> {action} статус админа.", parse_mode="HTML")
    await callback.answer()

@dp.message(F.document)
async def handle_zip(msg: Message):
    user_id = msg.from_user.id
    if not check_premium(user_id):
        data = get_user_data(user_id)
        if data["daily_count"] >= DAILY_LIMIT:
            return await msg.answer(f"⛔ Лимит исчерпан ({DAILY_LIMIT}/{DAILY_LIMIT}).\n\nКупи Премиум за {PREMIUM_PRICE} ⭐!", reply_markup=get_main_keyboard(user_id))
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
            if not (file_info.filename.endswith(".pwn") or file_info.filename.endswith(".inc") or file_info.filename.endswith(".lang")): continue
            content = base64.b64encode(z.read(file_info.filename)).decode()
            url = f"https://api.github.com/repos/{REPO}/contents/{temp_dir}/{file_info.filename}"
            requests.put(url, headers=gh_headers, json={"message": "Upload", "content": content})
    await msg.answer("🚀 Файлы загружены. Запускаю компиляцию...")
    wf_url = f"https://api.github.com/repos/{REPO}/actions/workflows/compile.yml/dispatches"
    requests.post(wf_url, headers=gh_headers, json={"ref": "main", "inputs": {"request_id": request_id, "source_dir": temp_dir}})
    if not check_premium(user_id):
        update_user_count(user_id)
    for _ in range(100):
        await asyncio.sleep(5)
        runs = requests.get(f"https://api.github.com/repos/{REPO}/actions/runs", headers=gh_headers).json()
        run = next((r for r in runs["workflow_runs"] if r["name"] == "Compile Pawn"), None)
        if run and run["status"] == "completed":
            if run["conclusion"] == "success":
                arts = requests.get(run["artifacts_url"], headers=gh_headers).json()
                if not arts["artifacts"]:
                    return await msg.answer("❌ Артефакт не найден.")
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
    await msg.answer("⌛ GitHub слишком долго думает. Попробуй позже.")

@dp.message(F.text == "❓ Помощь")
async def help_msg(msg: Message):
    await msg.answer("1. Скинь ZIP-архив с модом.\n2. Забери готовый .amx.\n\nБесплатно: 3 компиляции в день.")

@dp.message(F.text == "📂 Отправить мод ZIP")
async def send_zip_msg(msg: Message):
    await msg.answer("Жду твой ZIP-архив! 📦")

async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
