--Magical Girl Magi Mami
--
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x7dd)
	c:SetCounterLimit(0x7dd,5)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	--cannot target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(s.ritlimit)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.indval)
	c:RegisterEffect(e3)
	--summon success
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.addcost)
	c:RegisterEffect(e4)
	--attackup
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetValue(s.attackup)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6)
	--Banish face down
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_REMOVE)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCountLimit(1,{id,1})
	e7:SetCost(s.cost)
	e7:SetTarget(s.rmtg)
	e7:SetOperation(s.rmop)
	c:RegisterEffect(e7)
	--Negate summon
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_SUMMON_SUCCESS)
	e8:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1,{id,2})
	e8:SetCost(s.cost)
	e8:SetTarget(s.negtg)
	e8:SetOperation(s.negop)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e10)
	--cost
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,3))	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
e11:SetCategory(CATEGORY_COUNTER)
	e11:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e11:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e11:SetCountLimit(1)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCondition(s.mtcon)
	e11:SetOperation(s.ccost)
	c:RegisterEffect(e11)
	--self destroy
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e12:SetRange(LOCATION_MZONE)
	e12:SetCode(EFFECT_SELF_DESTROY)
	e12:SetCondition(s.descon)
	c:RegisterEffect(e12)
	--place counter
	local e13=Effect.CreateEffect(c)
	e13:SetDescription(aux.Stringid(id,4))
	e13:SetCategory(CATEGORY_COUNTER)
	e13:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e13:SetType(EFFECT_TYPE_IGNITION)
	e13:SetRange(LOCATION_MZONE)
	e13:SetCountLimit(1,{id,3})
	e13:SetCost(s.cost)
	e13:SetTarget(s.tg)
	e13:SetOperation(s.op)
	c:RegisterEffect(e13)
	--draw 1 revel if be monster, you can special summon it
	local e14=Effect.CreateEffect(c)
	e14:SetDescription(aux.Stringid(id,5))
	e14:SetCategory(CATEGORY_COUNTER)
	e14:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e14:SetType(EFFECT_TYPE_IGNITION)
	e14:SetRange(LOCATION_MZONE)
	e13:SetCountLimit(1,{id,4})
	e14:SetCost(s.cost)
	e14:SetTarget(s.target)
	e14:SetOperation(s.operation)
	c:RegisterEffect(e14)
end
s.listed_series={0x7DB,id}
s.listed_names={"ID.Contract"}
s.counter_place_list={0x7dd}
function s.ritlimit(e,se,sp,st)
	if (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL then
		return se:GetHandler():IsCode("ID.Contract")
	end
	return true
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.addcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsCanAddCounter(tp,0x7dd,5,c) end
	c:AddCounter(0x7dd,5)
end
function s.attackup(e,c)
	return c:GetCounter(0x7dd)*400
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x7dd,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x7dd,1,REASON_COST)
end
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
function s.desfilter(c,tp)
    return c:IsFaceup() and c:IsSummonPlayer(1-tp)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.desfilter,1,nil,tp) end
    local g=eg:Filter(s.desfilter,nil,tp)
    local dam=g:GetSum(Card.GetBaseAttack)//2
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.desfilter,nil,tp)
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
        local dam=g:GetSum(Card.GetBaseAttack)//2
        Duel.Damage(1-tp,dam,REASON_EFFECT)
    end
end
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.ccost(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsCanRemoveCounter(tp,1,0,0x7dd,1,REASON_COST) then
		Duel.RemoveCounter(tp,1,0,0x7dd,1,REASON_COST)
	end
end
function s.descon(e)
	return e:GetHandler():GetCounter(0x7dd)==0 and not e:GetHandler():IsStatus(STATUS_SUMMON_TURN|STATUS_FLIP_SUMMON_TURN|STATUS_SPSUMMON_TURN)
end
function s.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x7dd,1) and not c:IsCode(id)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x7dd)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) then
		if tc:IsRelateToEffect(e) then
			tc:AddCounter(0x7dd,1)
		end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		Duel.ConfirmCards(1-tp,tc)
		Duel.BreakEffect()
		if tc:IsMonster() and tc:IsSetCard(0x7DB) then
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		Duel.ShuffleHand(tp)
	end
end