
local s, t = string, table
local ss = s.sub

--------------------------------------------------------------------------------
local POS_BITS = 12
local LEN_BITS = 16 - POS_BITS
local POS_SIZE = 1 << POS_BITS
local LEN_SIZE = 1 << LEN_BITS
local LEN_MIN = 3

local function lzss_decompress(input)
	local offset, output = 1, {}
	local window = ''

	while offset <= #input do
		local flags = s.byte(input, offset)
		offset = offset + 1

		for i = 1, 8 do
			local str = nil
			if (flags & 1) ~= 0 and offset <= #input then
				str = ss(input, offset, offset)
				offset = offset + 1
			elseif offset + 1 <= #input then
				local tmp = s.unpack('>I2', input, offset)
				offset = offset + 2
				local pos = (tmp >> LEN_BITS) + 1
				local len = (tmp & (LEN_SIZE - 1)) + LEN_MIN
				str = ss(window, pos, pos + len - 1)
			end
			flags = flags >> 1
			if str then
				output[#output + 1] = str
				window = ss(window .. str, -POS_SIZE)
			end
		end
	end

	return t.concat(output)
end
return print(lzss_decompress("�local a=�..._BIOS�=\"Zorya �NEO\"_ZVSTR=\"2.0��ER=@;_ZPwAT=GIT a9eec0\" �b={}b.li�bs  c=3;�b.search��d0�;fun�ction kr�equire(e�)if c[e]�then ret�urn	�end;�for f=1,�#d do  g�=d[f]	�g �\n\"	�=g()\n{ �! 	=	;c�[\"thd\"]=M(u() 'i��j=1�comp�uter=��u�npack=C ~ptable.C�Vroutine�@��.cre�at�l8yie�l�m8resu�m�n8stat�usgh.add�(o,ptq=a�ssert(k(�p))i[#i+�1]={o,q,�{},0,\".+\"}i[q]=\"a� r�sF.p�ullSigna�l�utosle�epet=mat�h.hugeWi�	�i�[4]a,*�<t\rst$*��Ku=t-%�up�time(	�u<�0#r>0\rsu�=0xv={s(�u)}if/�1�v^/�r[#r\"�vr�v=r[1]Sr�emove(r,C1)!\nt3� w 6�ruPw='�)��+d%�.�/pw1� n�(*�2])~=\"7�ning`\n@ _x,y=m<�,C�(w\"@<�ot x�\rserror<�1�]..\": \".�.y5R	�y==\"�k=�*�6]=tr�uery:�+(yp(�\"P*�=y;3.100)}q6�)�� z,R<rz=de'ad\"+@QzC�\n\"�q[#q\"�z;q�[K� M�6i=q�5�#i/�\" ki�ll(fF�C��s�ched_ 5#�i==jPMget�_th�ds6iPK%�l(qEY!5hh1)e%�&��	�bt6�@syst�em�l A6�A�q!�)while�7�KBpa(pr�otectS�7�C�,o)o=o\"�lkprc$B B��DI�E,z i�n pairs(�_GcD[EN�;�D._ENV=D�jGjr&nil;� �!�loade�\"�=B o,\"t\",GD))5Ra( �_P�(F,G)c[F�]=GPKo#�(H_)d[#d\"�Hr\ntAZ�_�_]^()I]x�l^UA]xt1|t�onentB�zB_zJ=fal�s�K6�log(r �)zexy(W�list(\"ocoemu\"[).~�\"�Lp vM\"  ��\"zyneof�L� ��N N.w�s�=�O6�O.deObug_~� Pz�:��s+box��pȀ_�t	�P\rtfinvoke(P,��g\",�DPKO.b� �r(QtQ=Q�:gsub(\"-\",\"\",Dt�\"fQ,2R=�R.pr=�.ch�ar(tonum�be��:��f,f?+1),16n3\nt�R��V1fb`(S,9T�� U,g�x�4�S,\"V1\",T,�FH@3U +\rdAg^5RR=U;bCU�����F��b(Ufa\"��7\n\"b�k6��,?\"close�`E���d( copy(V,W)W=W��X={[V]=�W�Y={V�Zo={W}bB#Y/��g�Y4 c	�ty�pe(z=1R=�Zp4 it}`*aX[z\nౕ���2I'��q;Y�[#YM�Z[#Z6\"�q;��=q5rR4ZZ504ZY5;Wr��Oro'\"z1\",Z�_�a0�G16��a0��admod�(a2	�a1[aQ2\n�s*_g�P'#_,�E_��,\rd�s=g5�g�:���ere�pn p(D�nK�`oA��q�p)_�[#_\"�p�g(#_�>lkpPO�U�V�opiQ�ZU�jDAs5ha0R�� 3�' �o�����Ϟ��/�_��o�������� 4¾G5�x��( roym��U�Datae�a6=a5�1,�36)��4U��a�7tT!���a6,�\"open\",am7� \")Ea3�!�T�<4.ex� s��\nu�?,\"�C�5R��P��=a6�]a8h��	�V�$4)B�\\27ZLS=�V=a(��5��l��cz!M�x;xp   Qp���]���)������&\".zy2/v��s/?�a2 ?0���`��8(�(�����f�����ǰt���/init�����o�h@�o�M��I2_Z�LN�� ���o��W0�^��������\"���_� ����o�d�����5���9=��cfg.l�u��=f�2=a0,����P����m���,_�BOOTADDR �1cQ9_9_9�8�e:Xa9:@zy� _�:#���,ˇa)x=a�aUS\".tracCeb�a�	x�(�\n"), "=bios.lua")(lzss_decompress)