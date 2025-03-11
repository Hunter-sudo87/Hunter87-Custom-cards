--トゥーン・マーメイド
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Destruction replacement
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	c:RegisterEffect(e4)
	--Direct attack
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(s.dircon)
	c:RegisterEffect(e5)
	--cannot attack
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetOperation(s.atklimit)
	c:RegisterEffect(e7)
end
s.listed_names={15259703}
s.listed_series={0x62}
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),aux.TRUE,1,false,1,true,c,c:GetControler(),nil,false,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD) and c:IsCode(15259703) 
		and not c:IsReason(REASON_REPLACE+REASON_BATTLE)
end
function s.tgfilter(c,e)
	return c:IsType(TYPE_TOON) and c:IsReleasableByEffect(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED|STATUS_BATTLE_DESTROYED)
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer(),c:GetReasonPlayer())
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and Duel.CheckReleaseGroupCost(tp,s.tgfilter,1,false,nil,nil,tp) end
    if Duel.SelectEffectYesNo(tp,c,96) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        local rg=Duel.SelectReleaseGroupCost(tp,s.tgfilter,1,1,false,nil,nil,tp)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(rg:GetFirst():GetAttack())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        Duel.Release(rg,REASON_COST)
    end
end
function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function s.dircon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		and not Duel.IsExistingMatchingCard(s.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function s.atklimit(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end