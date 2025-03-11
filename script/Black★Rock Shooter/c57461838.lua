--Pain★Cat - B★R☆S
local s,id=GetID()
function s.initial_effect(c)
	--no damage and return all monsters your opponent to hand 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.nodmgcon)
	e1:SetCost(s.nodmgcost)
	e1:SetTarget(s.nodmgtg)
	e1:SetOperation(s.nodmgop)
	c:RegisterEffect(e1)
	--Special summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
end
s.listed_series={0x620}
function s.nodmgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()==nil and tp~=Duel.GetTurnPlayer() and Duel.GetBattleDamage(tp)>0 and Duel.GetLP(tp)<1000
end
function s.nodmgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.nodmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.nodmgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Avoid Damage this battle
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
	--Return all opponent's monsters to the hand
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
	Duel.SendtoHand(g,nil,REASON_EFFECT) 
	end
end
function s.spfilter(c)
	return c:IsFaceup() and c:IsLevel(5) and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x620)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end