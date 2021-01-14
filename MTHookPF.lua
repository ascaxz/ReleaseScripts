
local A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,Old,T,U,V,W,X,Y,Z = ...

return function(self, K)
	if A then
		if B[W] and B[W][X] and (self == B[W].barrel or C(self) == D) and K == E then
			local Player = (F and G() or H())
			local Char = (Player and I[Player])
			local Chosen = J == K and L[M:NextInteger(1, #L)] or J
			local ChosenBodyPart = (Char and N(Char.rootpart.Parent, Chosen))
			if ChosenBodyPart then
				local _, TimeToHit = O(self[T], P, ChosenBodyPart[T], B[V][W][Z])
				return S(self[T], ChosenBodyPart[T] + (Q(unpack(R)) * (TimeToHit ^ 2)) + (ChosenBodyPart.Parent[Y][U] * TimeToHit))
			end
		end
	end
	return Old(self, K)
end
