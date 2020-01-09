net.timeout=60
function net.open(A,V)
local st,F,P,D=computer.uptime()
net.send(A,V,"openstream")
repeat
_,F,P,D=computer.pullSignal(0.5)
if computer.uptime()>st+net.timeout then return false end
until F==A and P==V and tonumber(D)
V=tonumber(D)
repeat
_,F,P,D=computer.pullSignal(0.5)
until F==A and P==V
return net.socket(A,V,D)
end
