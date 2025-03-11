--Courage
--
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Shuffle monster into the Deck and increase the ATK of another monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function() return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated() end)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_names={21175632,56398460}
s.listed_series={0x591}
function s.filter(c,p)
	return c:IsOnField() and c:IsControler(p)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.filter,1,nil,tp) and Duel.IsChainNegatable(ev)
		and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.filter1(c)
	return (c:IsMonster() and c:IsSetCard(0x591)) or c:IsCode(21175632)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
function s.damfilter(c)
	return c:IsFaceup() and (c:IsMonster() and c:IsSetCard(0x591)) or c:IsCode(21175632) and c:GetAttack()>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.damfilter,tp,LOCATION_MZONE,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tc=g:Select(tp,1,1,nil):GetFirst()
			Duel.HintSelection(tc,true)
			local dam=tc:GetAttack()
			Duel.BreakEffect()
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
function s.atkfilter(c,tp)
	return c:IsFaceup() and c:IsCode(21175632) and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.tdfilter(c,code)
	return c:IsMonster() and c:IsSetCard(0x591) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tdc=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil,tc:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tdc,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local tc=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	local atkc=g:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and atkc and atkc:IsFaceup() and atkc:IsControler(tp) then
		atkc:UpdateAttack(atkc:GetBaseAttack(),RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,e:GetHandler())
	end
end