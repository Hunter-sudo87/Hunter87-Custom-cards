--Djinn
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	Spirit.AddProcedure(c,EVENT_SPSUMMON_SUCCESS)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Apply effects
	local e2=Effect.CreateEffect(c)
	--e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_card_types={TYPE_SPIRIT}
function s.cfilter(c,ft)
	return c:IsType(TYPE_SPIRIT) and c:IsAbleToHandAsCost() and (ft>0 or c:GetSequence()<5)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp)
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.cosfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsMonster()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cosfilter,1,false,nil,e:GetHandler()) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cosfilter,1,1,false,nil,e:GetHandler())
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetFlagEffect(1-tp,id+1)==0
	local b3=Duel.GetFlagEffect(1-tp,id+2)==0
	if chk==0 then return b1 or b2 or b3 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetFlagEffect(1-tp,id+1)==0
	local b3=Duel.GetFlagEffect(1-tp,id+2)==0
	local dtab={}
	if b1 then
		table.insert(dtab,aux.Stringid(id,0))
	end
	if b2 then
		table.insert(dtab,aux.Stringid(id,1))
	end
	if b3 then
		table.insert(dtab,aux.Stringid(id,2))
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVEEFFECT)
	local op=Duel.SelectOption(tp,table.unpack(dtab))+1
	if not (b1 or b2) then op=3 end
	if not (b1 or b3) then op=2 end
	if (b1 and b3 and not b2 and op==2) then op=3 end
	if (b2 and b3 and not b1) then op=op+1 end
	if op==1 then
		--Add 1 Spirit monster
		if not c:IsRelateToEffect(e) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
end
	elseif op==2 then
		--You can Normal Summon/Set 1 Spirit monster in addition
		Duel.RegisterFlagEffect(1-tp,id+1,RESET_PHASE+PHASE_END,0,1)
		aux.RegisterClientHint(c,nil,tp,0,1,aux.Stringid(id,6),nil)
		local e2=Effect.CreateEffect(c)
	    e2:SetType(EFFECT_TYPE_FIELD)
	    e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	    e2:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	    e2:SetRange(LOCATION_MZONE)
	    e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPIRIT))
	    e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
	elseif op==3 then
		--Spirit monsters you control do not have to have their effects that return them to the hand activated
		Duel.RegisterFlagEffect(1-tp,id+2,RESET_PHASE+PHASE_END,0,1)
		aux.RegisterClientHint(c,nil,tp,0,1,aux.Stringid(id,7),nil)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
	    e3:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
	    e3:SetRange(LOCATION_MZONE)
	    e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.thfilter(c)
	return c:IsType(TYPE_SPIRIT) and not c:IsCode(id) and c:IsAbleToHand() 
end
