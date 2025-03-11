--Kozmo－フェルブラン
local s,id=GetID()
function s.initial_effect(c)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x7d4}
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x7d4) and c:IsLevelBelow(7) and c:IsAbleToHand() and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	Duel.PayLPCost(tp,800)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rvg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and rvg:GetClassCount(Card.GetCode)>=3 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsChainDisablable(0) then
		local sel=1
		local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_HAND,nil)
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,0))
		if #g>0 then
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
			Duel.NegateEffect(0)
			return
		end
	end
	local rvg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local rg=aux.SelectUnselectGroup(rvg,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,rg)
	local tg=rg:RandomSelect(1-tp,1)
	local tc=tg:GetFirst()
	if tc and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end 