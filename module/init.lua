-- Multiple Games
--
-- The game refuses to start a second time: right at the start it creates the mutex
-- "Global\FireflyStrongholdCrusadersExtreme" (both exes use the same name) and, when
-- GetLastError says it already exists (0xB7), shows "Stronghold Crusader is already running."
-- and quits. The `jne` after `cmp eax, 0xB7` becomes a `jmp`, so the game always carries on.
-- Found by pattern scan; the same bytes in Stronghold Crusader.exe and
-- Stronghold_Crusader_Extreme.exe.

-- call [GetLastError] / cmp eax, 0xB7 / jne <go on> / push ebp / call [CloseHandle] / push ebx / push
local ALREADY_RUNNING_AOB = "FF 15 ? ? ? ? 3D B7 00 00 00 75 ? 55 FF 15 ? ? ? ? 53 68"
local JUMP_OFFSET = 11
local JNE_SHORT, JMP_SHORT = 0x75, 0xEB

local M = {}

function M:enable()
  local site = core.scanForAOB(ALREADY_RUNNING_AOB)
  if site == nil or site == 0 then
    log(WARNING, "multiple-games: the already-running check was not found; the game stays single")
    return
  end
  local jump = site + JUMP_OFFSET
  if core.readByte(jump) & 0xFF ~= JNE_SHORT then
    log(WARNING, "multiple-games: the already-running check is not the one this module knows")
    return
  end
  core.writeCode(jump, { JMP_SHORT })
  log(INFO, "multiple-games: the game may run more than once")
end

function M:disable() end

return M
