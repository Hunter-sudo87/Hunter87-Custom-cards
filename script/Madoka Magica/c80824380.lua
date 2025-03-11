--Magical Girl Magi Kyoko
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
	e1:SetValue(s.ritlimit)
	c:RegisterEffect(e1)
	--cannot target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
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
	--pierce
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetRange(LOCATION_MZONE)
	e8:SetHintTiming(TIMING_DAMAGE_STEP)
	e8:SetCountLimit(1,{id,2})
	e8:SetCost(s.cost)
	e8:SetTarget(s.atktg)
	e8:SetOperation(s.atkop)
	c:RegisterEffect(e8)
	--place counter
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,3))
	e9:SetCategory(CATEGORY_COUNTER+CATEGORY_DRAW)
	e9:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCountLimit(1,{id,3})
	e9:SetCost(s.cost)
	e9:SetTarget(s.tg)
	e9:SetOperation(s.op)
	c:RegisterEffect(e9)
	--draw 1 send to gy, your opponent cannot activate cards, or the effects of cards, with the same original type (Monster/Spell/Trap) as the card you sent to the GY on your opponent's next turn
	local e10=Effect.CreateEffect(c)
	e10:SetDescription(aux.Stringid(id,4))
	e10:SetCategory(CATEGORY_COUNTER)
	e10:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e10:SetType(EFFECT_TYPE_IGNITION)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCountLimit(1,{id,4})
	e10:SetCost(s.cost)
	e10:SetTarget(s.target)
	e10:SetOperation(s.activate)
	c:RegisterEffect(e10)
	--cost
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,5))	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
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
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(tc:GetDefense()/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
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
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    e:GetLabelObject(tc)
    g:KeepAlive()
    if Duel.Draw(tp,1,REASON_EFFECT)>0 then
        if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_ACTIVATE)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetTargetRange(0,1)
            e1:SetValue(s.actlimit(tc))
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
            Duel.RegisterEffect(e1,tp)
            local e2=Effect.CreateEffect(e:GetHandler())
           e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
           e2:SetDescription(aux.Stringid(id,2))
           e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
           e2:SetTargetRange(0,1)
           Duel.RegisterEffect(e2,tp)
        end
    end
end
function s.actlimit(tc)
    return function(e,re,tp)
        return re:IsActiveType(tc:GetOriginalType())
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
