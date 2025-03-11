--Malefic Domination
--
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.thtg1)
	e1:SetOperation(s.thop1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(75223115)
	c:RegisterEffect(e2)
	--malefic change
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(id)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
	--adjust
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(s.adjustop)
	e4:SetCondition(s.validitycheck)
	c:RegisterEffect(e4)
	--cannot summon,spsummon,flipsummon
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetTarget(s.sumlimit)
	e5:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e7)
	-- Add 1 "Malefic"card to the hand
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
	e8:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e8:SetCode(EVENT_BATTLE_DAMAGE)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCountLimit(1,id)
	e8:SetTarget(s.thtg2)
	e8:SetOperation(s.thop2)
	c:RegisterEffect(e8)
	--disable
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_DISABLE)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e7:SetCondition(s.discon)
	e7:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x23))
	c:RegisterEffect(e7)
end
s.listed_series={0x23}
s.listed_names={27564031}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.thfilter1(c)
	return (c:IsCode(27564031)) or c:IsSetCard(0x23) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.discon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.stuff(c)
	local mt=c:GetMetatable()
	return c:IsFaceup() and mt.has_malefic_unique and mt.has_malefic_unique[c]==true and not c:IsDisabled() and c:IsSetCard(0x23)
end
function s.checkok(c,group)
	return group:IsExists(s.rmfilter2,1,c,c:GetFieldID(),c:GetCode())
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsSetCard),0,LOCATION_MZONE,LOCATION_MZONE,nil,0x23)
	local sg=g:Filter(s.checkok,nil,g)
	if #sg>0 then
		Duel.Destroy(sg,REASON_RULE)
		Duel.Readjust()
	end
end
function s.validitycheck()
	return Duel.IsExistingMatchingCard(s.stuff,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.rmfilter(c,...)
	return c:IsFaceup() and c:IsSetCard(0x23) and c:IsCode(...)
end
function s.rmfilter2(c,fieldid,...)
	return c:GetFieldID()<fieldid and c:IsCode(...)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	if (not s.stuff(c) or not s.validitycheck()) then return false end
	local tp=sump
	if targetp then tp=targetp end
	return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetCode())
end
function s.thfilter2(c)
	return c:IsSetCard(0x23) and c:IsAbleToHand()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(c) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end