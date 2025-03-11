--Oktavia
--
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Treat its Rank as 0
	c:SetStatus(STATUS_NO_LEVEL,true)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--summon limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(18175965,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_HAND+LOCATION_DECK)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--Can attack all monsters
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_ATTACK_ALL)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--Banish monsters destroyed by battle
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e6:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e6)
	--Activate 1 "Magical Girl Despair" from hand or deck
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,id)
	e7:SetTarget(s.tftg)
	e7:SetOperation(s.tfop)
	c:RegisterEffect(e7)
	--spsummon success
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	e8:SetOperation(s.sucop)
	c:RegisterEffect(e8)
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	e9:SetOperation(s.tgop)
	c:RegisterEffect(e9)
	--disable summon
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCode(EFFECT_CANNOT_SUMMON)
	e10:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e10:SetTargetRange(1,0)
	c:RegisterEffect(e10)
	local e11=e10:Clone()
	e11:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e11)
end
s.listed_names={96243532,45865771}
s.listed_series={0x131}
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_DESTROY)
		and c:GetReasonEffect() and c:GetReasonEffect():GetOwner()==c and c:IsCode(96243532)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,1,tp,tp,true,false,POS_FACEUP_ATTACK)>0 then
		c:CompleteProcedure()
	end
end
function s.rmfilter(c,p)
	return Duel.IsPlayerCanRemove(p,c) and not c:IsType(TYPE_TOKEN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local ct=#g-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ct=ct-1 end
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,30459350)
		and ct>0 and g:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEUP,REASON_RULE) end
	--Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(1-tp,30459350) then return end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local ct=#g-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg=g:FilterSelect(1-tp,Card.IsAbleToRemove,ct,ct,nil,1-tp,POS_FACEUP,REASON_RULE)
		Duel.Remove(sg,POS_FACEUP,REASON_RULE,PLAYER_NONE,1-tp)
	end
end
function s.filter(c,tp)
	return c:IsCode(45865771) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
	if not Duel.CheckPhaseActivity() then Duel.RegisterFlagEffect(tp,CARD_MAGICAL_MIDBREAKER,RESET_CHAIN,0,1) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,e:GetHandler())
	Duel.SendtoGrave(g,REASON_EFFECT)
end
