--Magical Girl Kyubey
--
local s,id=GetID()
function s.initial_effect(c)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.tgoval)
	e1:SetCondition(s.tgcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	c:RegisterEffect(e2)
	--Ritual Summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.cost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.listed_names={id}
s.listed_series={0x7DB}
function s.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x7DB) and c:IsRitualMonster()
end
function s.tgcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter1,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.cfilter2(c,e,tp,ft)
	local lv=c:GetOriginalLevel()
	local rc=c:GetBaseAttack()
	local att=c:GetOriginalAttribute()
	local eff4064256={Duel.GetPlayerEffect(tp,4064256)}
	for _,te in ipairs(eff4064256) do
		local val=te:GetValue()
		if val and val(te,c,e,0) then rc=val(te,c,e,1) end
	end
	local eff12644061={Duel.GetPlayerEffect(tp,12644061)}
	for _,te in ipairs(eff12644061) do
		local val=te:GetValue()
		if val and val(te,c,e,0) then att=val(te,c,e,1) end
	end
	return lv>0 and c:IsFaceup() and not c:IsRitualMonster() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGraveAsCost() and (ft>0 or c:GetSequence()<5)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,lv+2,rc,att,e,tp)
end
function s.spfilter(c,lv,atk,att,e,tp)
	return c:IsLevel(lv) and c:IsAttack(atk) and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(att) and c:IsRitualMonster() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true)
end 
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return ft>-1 and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp,ft)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	Duel.SendtoGrave(tc,REASON_COST)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsLocation(LOCATION_GRAVE) or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tc:GetLevel()+2,tc:GetAttack(),tc:GetAttribute(),e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)
	end
end
function s.filter(c)
	return c:IsSpellTrap() or (c:IsCode(id) and c:IsFaceup())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end