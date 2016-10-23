function trim(str)
    local s = str:gsub('^%s*(.-)%s*$', '%1')
    return s
end
function md_skip(text)
 return text:gsub('_', '\\_')
        :gsub('%[', '\\[')
        :gsub('%]', '\\]')
        :gsub('%*', '\\*')
        :gsub('`', '\\`')
end

function stats(lang,msg)
  users_info = {}
  local msgs = {}
  for k,v in pairs (data.word[tostring(msg.chat.id)]) do
   msgs.count = v
   msgs.word = k
   --print(msgs.count,msgs.word)
   table.insert(users_info,msgs)
   msgs = {}
  end
  for i,e in pairs(users_info) do
   print(i,e)
  end
  table.sort(users_info, function(a, b) 
      if a.count and b.count then
        return a.count > b.count
      end
    end)

  local text = ''
  local num = 1
  for k,user in pairs(users_info) do
   if lang == "Arb" then
    if URL.unescape(user.word):find("[ا-ي]") then
     if num <= 10 then
      if user.word ~= "" then
      
    text = text..md_skip(URL.unescape(user.word))..'` => `*'..user.count..'*\n'
   end
   end
    num = num +1
   end
  elseif lang == "Eng" then
     if not URL.unescape(user.word):find("[ا-ي]") then
       if num <= 10 then
       if user.word ~= "" then
      
    text = text.."*"..md_skip(URL.unescape(user.word))..'*` => `*'..user.count..'*\n'
   end
       end
     num = num +1
   end
 else
 
   if num <= 10 then
      if user.word ~= "" then
      
    text = text.."*"..md_skip(URL.unescape(user.word))..'*` => `*'..user.count..'*\n'
   end
   end
    num = num +1
    end
  end
  print(num)
 -- if num == 10 then
  return text
 -- end
end
function keyboardmaker(id)
   local keyboard = {}
  keyboard.inline_keyboard = {{{text = "BACK",callback_data="Back"..id},{text = "رجوع",callback_data="Back"..id},},}
  return keyboard
end
local function run(msg,matches)

 if matches[1] == "##audio##" or  matches[1] == "##forward##" or  matches[1] == "##photo##" or  matches[1] == "##video##" or  matches[1] == "##document##" or  matches[1] == "##sticker##" or  matches[1] == "##voice##" or  matches[1] == "##contact##" or  matches[1] == "##new_chat_member##" then
 return
 end
 data = load_data("data.db")
 data.word = data.word or {}
 data.word[tostring(msg.chat.id)] = data.word[tostring(msg.chat.id)] or {}
 if matches[1]:match("#in:Eng%d+") then
  if matches[1] == "#in:Eng"..msg.from.id then
  editMessageText(msg.chat.id,msg.message_id,"*TOP 10 words :-*\n"..stats("Eng",msg),JSON:encode(keyboardmaker(msg.from.id)),true)
  answerCallbackQuery(msg.cb_id,"English words stats")
else
  answerCallbackQuery(msg.cb_id,"send /stat please")
  end
 return
elseif matches[1]:match("#in:Arb%d+") then
 if matches[1] == "#in:Arb"..msg.from.id then
 editMessageText(msg.chat.id,msg.message_id,"أول 10 كلمات مستخدمه بكثره :-\n"..stats("Arb",msg),JSON:encode(keyboardmaker(msg.from.id)),true)
  answerCallbackQuery(msg.cb_id,"تم اختيار احصائيه العربيه")
   else
  answerCallbackQuery(msg.cb_id,"ارسل كلمه /stat رجاءا")
  end
 return
elseif matches[1]:match("#in:both%d+") then
 print(msg.from.id,msg.message_id,msg.chat.id)
 if matches[1] == "#in:both"..msg.from.id then
  editMessageText(msg.chat.id,msg.message_id,"*TOP 10 words :-*\n"..stats("both",msg),JSON:encode(keyboardmaker(msg.from.id )),true)
   answerCallbackQuery(msg.cb_id,"both words stats")
    else
  answerCallbackQuery(msg.cb_id,"send /stat please")
   end
 return
elseif matches[1]:match("#in:Back%d+") then
 if matches[1] == "#in:Back"..msg.from.id then
  local keyboard = {}
   keyboard.inline_keyboard = {{{text = "Eng",callback_data="Eng"..msg.from.id},{text = "Arb",callback_data="Arb"..msg.from.id},{text = "both",callback_data = "both"..msg.from.id}}}
 editMessageText(msg.chat.id,msg.message_id,"**choose the option that u want from me to show up the stat with.**",JSON:encode(keyboard),true)
  answerCallbackQuery(msg.cb_id,"Back- الرجوع")
   else 
  answerCallbackQuery(msg.cb_id,"send /stat please")
  end
 return
 end
 if matches[1] == "/stat" then
  save_data("data.db",data)
  local keyboard = {}
  keyboard.inline_keyboard = {{{text = "Eng",callback_data="Eng"..msg.from.id},{text = "Arb",callback_data="Arb"..msg.from.id},{text = "both",callback_data = "both"..msg.from.id}}}
  sendMessage(msg.chat.id,"**choose the option that u want from me to show up the stat with.**",true,false,true,JSON:encode(keyboard))
  return
 end
 matches[1] = URL.escape(matches[1]:gsub("%%0A","%%20")):lower()
 if not matches[1]:find("%%20") and not data.word[tostring(msg.chat.id)][matches[1]] then
  data.word[tostring(msg.chat.id)][matches[1]] = 1
  save_data("data.db",data)
  return
 end
 if not matches[1]:find("%%20") and data.word[tostring(msg.chat.id)][matches[1]] then
  data.word[tostring(msg.chat.id)][matches[1]] = data.word[tostring(msg.chat.id)][matches[1]] + 1
  save_data("data.db",data)
 return
end
 if matches[1]:find("%%20") then
  matches[1] = matches[1]:gsub("%%20","%%0A")
  matches[1] = URL.unescape(matches[1])
  matches[1] = trim(matches[1])
  matches[1] = matches[1].."\nmico" -- do not remove this :)
  for l in matches[1]:gmatch("(.-)\n") do
   l = trim(l)
   l = URL.escape(l:gsub("\n",""):gsub(" ","")):lower()
   if data.word[tostring(msg.chat.id)][l] then
     data.word[tostring(msg.chat.id)][l] = data.word[tostring(msg.chat.id)][l] + 1
     save_data("data.db",data)
   end
   if not data.word[tostring(msg.chat.id)][l] then
    data.word[tostring(msg.chat.id)][l] = 1
     save_data("data.db",data)
   end
  end
  return
 end
return

end

return {
 
 
patterns = {
 "(.+)"
},
run = run
}
