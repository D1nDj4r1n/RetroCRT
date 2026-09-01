-- retrocrt syntax sample (not loaded by the theme)
local count = 42
local ready = true

-- comments stay dim
function boot(path)
  if ready then
    print("string / attention")
    return count
  end
  error("failure")
end
