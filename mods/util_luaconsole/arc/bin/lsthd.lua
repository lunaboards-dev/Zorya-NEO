local threads = krequire("thd").get_threads()
for i=1, #threads do
	print(threads[i][1])
end