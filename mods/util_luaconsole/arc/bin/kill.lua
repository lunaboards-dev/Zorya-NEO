local thd = krequire("thd")
local threads = thd.get_threads()
local n = ...
for i=1, #threads do
	if (threads[i][1] == n) then
		thd.kill(i)
		print("killed "..n)
	end
end