function OnEvent(event, arg)
    do
        local state_8, state_45, cached_bits, cached_bits_qty = 2, 0, 0, 0
        local prev_width, prev_bits_in_factor, prev_k = 0
        for c in GetDate():gmatch "." do
            state_45 = state_45 % 65537 * 23456 + c:byte()
        end

        local function get_53_random_bits()
            local value53 = 0
            for shift = 26, 27 do
                local p = 2 ^ shift
                state_45 = (state_45 * 233 + 7161722017421) % 35184372088832
                repeat
                    state_8 = state_8 * 76 % 257
                until state_8 ~= 1
                local r = state_8 % 32
                local n = state_45 / 2 ^ (13 - (state_8 - r) / 32)
                n = (n - n % 1) % 2 ^ 32 / 2 ^ r
                value53 = value53 * p + ((n % 1 * 2 ^ 32) + (n - n % 1)) % p
            end
            return value53
        end

        for j = 1, 10 do
            get_53_random_bits()
        end

        local function get_random_bits(number_of_bits)
            local pwr_number_of_bits = 2 ^ number_of_bits
            local result
            if number_of_bits <= cached_bits_qty then
                result = cached_bits % pwr_number_of_bits
                cached_bits = (cached_bits - result) / pwr_number_of_bits
            else
                local new_bits = get_53_random_bits()
                result = new_bits % pwr_number_of_bits
                cached_bits = (new_bits - result) / pwr_number_of_bits * 2 ^ cached_bits_qty + cached_bits
                cached_bits_qty = 53 + cached_bits_qty
            end
            cached_bits_qty = cached_bits_qty - number_of_bits
            return result
        end

        table = table or {}
        table.getn = table.getn or function(x)
                return #x
            end

        math = math or {}
        math.huge = math.huge or 1 / 0
        math.abs = math.abs or function(x)
                return x < 0 and -x or x
            end
        math.floor = math.floor or function(x)
                return x - x % 1
            end
        math.ceil = math.ceil or function(x)
                return x + (-x) % 1
            end
        math.min = math.min or function(x, y)
                return x < y and x or y
            end
        math.max = math.max or function(x, y)
                return x > y and x or y
            end
        math.sqrt = math.sqrt or function(x)
                return x ^ 0.5
            end
        math.pow = math.pow or function(x, y)
                return x ^ y
            end

        math.frexp = math.frexp or function(x)
                local e = 0
                if x == 0 then
                    return x, e
                end
                local sign = x < 0 and -1 or 1
                x = x * sign
                while x >= 1 do
                    x = x / 2
                    e = e + 1
                end
                while x < 0.5 do
                    x = x * 2
                    e = e - 1
                end
                return x * sign, e
            end

        math.exp = math.exp or function(x)
                local e, t, k, p = 0, 1, 1
                repeat
                    e, t, k, p = e + t, t * x / k, k + 1, e
                until e == p
                return e
            end

        math.log = math.log or function(x)
                assert(x > 0)
                local a, b, c, d, e, f = x < 1 and x or 1 / x, 0, 0, 1, 1
                repeat
                    repeat
                        c, d, e, f = c + d, b * d / e, e + 1, c
                    until c == f
                    b, c, d, e, f = b + 1 - a * c, 0, 1, 1, b
                until b <= f
                return a == x and -f or f
            end

        math.log10 = math.log10 or function(x)
                return math.log(x) / 2.3025850929940459
            end

        math.random = math.random or function(m, n)
                if m then
                    if not n then
                        m, n = 1, m
                    end
                    local k = n - m + 1
                    if k < 1 or k > 2 ^ 53 then
                        error("Invalid arguments for function 'random()'", 2)
                    end
                    local width, bits_in_factor, modk
                    if k == prev_k then
                        width, bits_in_factor = prev_width, prev_bits_in_factor
                    else
                        local pwr_prev_width = 2 ^ prev_width
                        if k > pwr_prev_width / 2 and k <= pwr_prev_width then
                            width = prev_width
                        else
                            width = 53
                            local width_low = -1
                            repeat
                                local w = (width_low + width) / 2
                                w = w - w % 1
                                if k <= 2 ^ w then
                                    width = w
                                else
                                    width_low = w
                                end
                            until width - width_low == 1
                            prev_width = width
                        end
                        bits_in_factor = 0
                        local bits_in_factor_high = width + 1
                        while bits_in_factor_high - bits_in_factor > 1 do
                            local bits_in_new_factor = (bits_in_factor + bits_in_factor_high) / 2
                            bits_in_new_factor = bits_in_new_factor - bits_in_new_factor % 1
                            if k % 2 ^ bits_in_new_factor == 0 then
                                bits_in_factor = bits_in_new_factor
                            else
                                bits_in_factor_high = bits_in_new_factor
                            end
                        end
                        prev_k, prev_bits_in_factor = k, bits_in_factor
                    end
                    local factor, saved_bits, saved_bits_qty, pwr_saved_bits_qty = 2 ^ bits_in_factor, 0, 0, 2 ^ 0
                    k = k / factor
                    width = width - bits_in_factor
                    local pwr_width = 2 ^ width
                    local gap = pwr_width - k
                    repeat
                        modk = get_random_bits(width - saved_bits_qty) * pwr_saved_bits_qty + saved_bits
                        local modk_in_range = modk < k
                        if not modk_in_range then
                            local interval = gap
                            saved_bits = modk - k
                            saved_bits_qty = width - 1
                            pwr_saved_bits_qty = pwr_width / 2
                            repeat
                                saved_bits_qty = saved_bits_qty - 1
                                pwr_saved_bits_qty = pwr_saved_bits_qty / 2
                                if pwr_saved_bits_qty <= interval then
                                    if saved_bits < pwr_saved_bits_qty then
                                        interval = nil
                                    else
                                        interval = interval - pwr_saved_bits_qty
                                        saved_bits = saved_bits - pwr_saved_bits_qty
                                    end
                                end
                            until not interval
                        end
                    until modk_in_range
                    return m + modk * factor + get_random_bits(bits_in_factor)
                else
                    return get_53_random_bits() / 2 ^ 53
                end
            end

        local orig_Sleep = Sleep
        function Sleep(x)
            return orig_Sleep(x - x % 1)
        end
    end

    --OutputLogMessage("Event: "..event.." Arg: "..arg.."\n")

    function pressKeySelf(key)
        PressKey(key)
        Sleep(math.random(100))
        ReleaseKey(key)

        Sleep(math.random(500, 1100))
    end

    if (event == "MOUSE_BUTTON_PRESSED" and arg == 5) then
        while (not IsKeyLockOn("capslock")) do
            for i = 1, 65 do
                OutputLogMessage(i)
                if (IsKeyLockOn("capslock")) then
                    break
                end
                
                if (i == 1) then
                    pressKeySelf("1")
                    pressKeySelf("6")
                    pressKeySelf("q")
                    pressKeySelf("w")
                    pressKeySelf("e")
                end
                
               if (i == 2) then
                    pressKeySelf("f3")
                    pressKeySelf("v")
                end
                
               if (i == 15 or i == 31 or i == 42) then
                     Sleep(50, 100)
                     PressKey('down', 'a')
                     Sleep(50, 100)
                     ReleaseKey('down', 'a')
                     Sleep(200, 300)
                     PressKey('right', 'a')
                     ReleaseKey('right', 'a')
                end
                                
                if (i == 16 or i == 32 or i == 43) then
                     Sleep(50, 100)
                     PressKey('up', 'a')
                     Sleep(50, 100)
                     ReleaseKey('up', 'a')
                     Sleep(200, 300)
                     PressKey('left', 'a')
                     ReleaseKey('left', 'a')
                end
                
                if (math.random(0, 100) > 70) then
                    --i = i + 1
                end
                
                if (i == math.random(15, 20)) then
                    pressKeySelf("4")
                end

                if (i == 25) then
                    pressKeySelf("f3")
                end
                
                -- 幽暗
                if (i % 1 == 0) then
                    pressKeySelf("c")
                    Sleep(100, 200)
                    if (i % math.random(2, 4) == 0) then
                        pressKeySelf("lctrl")
                        Sleep(100, 200)
                    end
                end
     
                -- QWE
                if (i % math.random(9, 12) == 0) then
                    pressKeySelf("q")
                    pressKeySelf("w")
                end

                if (i % math.random(9, 12) == 0) then
                    pressKeySelf("e")
                    pressKeySelf("q")
                end

                if (i % math.random(9, 12) == 0) then
                    pressKeySelf("e")
                    pressKeySelf("w")
                end

                -- 武公
                if (i % 45 == 0) then
                    pressKeySelf("f3")
                end

                -- 武公
                if (i % 29 == 0) then
                    pressKeySelf("1")
                    pressKeySelf("4")
                end
                
                -- f
                if (i % 24 == 0) then
                    pressKeySelf("f")
                end
                
                if (i % 36 == 0) then
                    pressKeySelf("f")
                    pressKeySelf("6")
                    pressKeySelf("f")
                end
                
                if (i % 22 == 0) then
                    pressKeySelf("q")
                    pressKeySelf("w")
                    pressKeySelf("E")
                end

                Sleep(math.random(500, 1000))
            end
        end
    end
end

--
