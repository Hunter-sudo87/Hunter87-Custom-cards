--Honey Gathering
--
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x269)
	--Activate and place 2 Honey Counters
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_COUNTER)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	--LP Cost replace
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(1,0)
	e4:SetCode(EFFECT_LPCOST_REPLACE)
	e4:SetCondition(function(e) return Duel.GetLP(e:GetHandlerPlayer())<=2000 end)
	e4:SetOperation(s.lrop)
	c:RegisterEffect(e4)
	--Gain LP
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
	--lp
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_RECOVER)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetCondition(s.lpcon)
	e6:SetTarget(s.lptg)
	e6:SetOperation(s.lpop)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
	--send to gy
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_SZONE)
	e7:SetOperation(s.tgop)
	c:RegisterEffect(e7)
end
s.counter_place_list={0x269}
s.counter_list={0x269}
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	e:GetHandler():AddCounter(0x269,2)
end
function s.lrop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x269,1)
end
function s.rccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.rcvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCounter(0x269)>0 end
	local val=c:GetCounter(0x269)*500
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
function s.rcvop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local d=e:GetHandler():GetCounter(0x269)*500
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Recover(p,d,REASON_EFFECT)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetCounter(0x269)>=1 then
		e:SetLabel(e:GetHandler():GetCounter(0x269))
	else
		e:SetLabel(0)
	end
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) 
		and not c:IsLocation(LOCATION_DECK) 
		and e:GetLabelObject():GetLabel()~=0
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabelObject():GetLabel()*500
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end