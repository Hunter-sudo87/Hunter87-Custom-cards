--Otherworld Hatred Heart
--
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--"Amazoness" monsters gain 1000 ATK during Damage Calculation
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
local e3=e2:Clone()
		e3:SetValue(s.atkval2)
		c:RegisterEffect(e3)
	local e4=e2:Clone()
		e4:SetValue(s.atkval3)
		c:RegisterEffect(e4)
	--selfdes if no clearworld
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_SELF_DESTROY)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.sdcon)
	c:RegisterEffect(e5)
	--banish monster
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BATTLED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTarget(s.rmtg)
	e6:SetOperation(s.rmop)
	c:RegisterEffect(e6)
	--Set 1 "Aquamirror" Spell/Trap during the End Phase
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetRange(LOCATION_GRAVE)
	e7:SetCountLimit(1,id)
	e7:SetCost(aux.bfgcost)
	e7:SetTarget(s.settg)
	e7:SetOperation(s.setop)
	c:RegisterEffect(e7)
end
s.listed_series={0x620}
s.listed_names={51298050}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,51298050),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.atkcon(e)
	s[0]=false
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
function s.atktg(e,c)
	return c==Duel.GetAttacker() and c:IsSetCard(0x620)
end
function s.atkval(e,c)
	local d=Duel.GetAttackTarget()
	if s[0] or c:GetAttack()<d:GetAttack() then
		s[0]=true
		return c:GetLevel()*300
	else return 0 end
end
function s.atkval2(e,c)
	local d=Duel.GetAttackTarget()
	if s[0] or c:GetAttack()<d:GetAttack() then
		s[0]=true
		return c:GetRank()*300
	else return 0 end
end
function s.atkval3(e,c)
	local d=Duel.GetAttackTarget()
	if s[0] or c:GetAttack()<d:GetAttack() then
		s[0]=true
		return c:GetLink()*300
	else return 0 end
end
function s.sdcon(e)
	return not Duel.IsEnvironment(51298050)
end
function s.check(c,tp)
	return c and c:IsControler(tp) and c:IsSetCard(0x620)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttackTarget()~=nil
		and (s.check(Duel.GetAttacker(),tp) or s.check(Duel.GetAttackTarget(),tp)) end
	if s.check(Duel.GetAttacker(),tp) then
		Duel.SetTargetCard(Duel.GetAttackTarget())
	else
		Duel.SetTargetCard(Duel.GetAttacker())
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function s.setfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(0x620) and c:IsSSetable() and not c:IsCode(id)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,e:GetHandler()) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end