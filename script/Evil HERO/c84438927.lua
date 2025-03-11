--Long Live to the Supreme King
local s,id=GetID()
function s.initial_effect(c)
	-- Banish and inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000000,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Add "Evil HERO" banished to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
s.listed_names={12071500,CARD_DARK_FUSION}
s.listed_series={0x6008}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase()
end
function s.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x6008) and c:IsType(TYPE_FUSION)
end
function s.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc) 
	    and Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil) 
	    and Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1+g2,2,0,0)
	local atk=g1:GetFirst():GetAttack()+g2:GetFirst():GetAttack()
	if atk>=5000 then
	    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g or g:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local atk=g:GetFirst():GetPreviousAttackOnField()+g:GetNext():GetPreviousAttackOnField()
	if atk>=5000 then
	    Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
function s.filter(c)
	return (c:IsCode(12071500) or c:IsCode(CARD_DARK_FUSION)) and c:IsAbleToHand()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
