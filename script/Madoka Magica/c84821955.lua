--Magical Girl Loniness
--
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Untargetable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.immtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Indes
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(s.tgvalue)
	c:RegisterEffect(e3)
	--cannot release
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_RELEASE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(1,1)
	e5:SetTarget(s.immtg)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--cannot be fusion material
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	c:RegisterEffect(e6)
	--cannot be link material
	local e7=e4:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e7)
	--cannot target
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e8:SetValue(aux.tgoval)
	c:RegisterEffect(e8)
	--indes
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e9:SetRange(LOCATION_FZONE)
	e9:SetValue(s.indval)
	c:RegisterEffect(e9)
	--self destroy
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e10:SetRange(LOCATION_FZONE)
	e10:SetCode(EFFECT_SELF_DESTROY)
	e10:SetCondition(s.descon)
	c:RegisterEffect(e10)
	--inactivate
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetCode(EFFECT_CANNOT_ACTIVATE)
	e11:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e11:SetRange(LOCATION_FZONE)
	e11:SetTargetRange(0,1)
	e11:SetValue(s.aclimit)
	c:RegisterEffect(e11)
end
s.listed_names={82968233}
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function s.immtg(e,c)
	return c:IsCode(82968233)
end
function s.tgvalue(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end
function s.descon(e)
	return not Duel.IsEnvironment(82968233)
end
function s.acfilter(c,cd)
	return c:IsFaceup() and c:IsCode(cd)
end
function s.aclimit(e,re,tp)
	return Duel.IsExistingMatchingCard(s.acfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,1,nil,re:GetHandler():GetCode())
end