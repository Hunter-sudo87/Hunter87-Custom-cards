--Alela
--
local s,id=GetID()
function s.initial_effect(c)
	--special summon rule
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon1)
	c:RegisterEffect(e1)
	--atkdown
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Opponent cannot activate the effects of monsters with 3000 or more ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.tgcond)
	e3:SetValue(function(e,re,tp) return re:IsMonsterEffect() and re:GetHandler():IsAttackBelow(2000) end)
	c:RegisterEffect(e3)
	--Can be treated as a non-tuner for the Synchro Summon of a LIGHT monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_NONTUNER)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(function(_,sc) return sc and sc:IsAttribute(ATTRIBUTE_DARK) and sc:IsType(TYPE_SYNCHRO) and sc:IsSetCard(0x7df) end)
	c:RegisterEffect(e4)
end
s.listed_series={0x7df}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7df) and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) and c:IsType(TYPE_SYNCHRO)
end
function s.spcon1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7df) and c:IsRace(RACE_FAIRY)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)*-300
end
function s.fspfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7df) and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) and c:IsType(TYPE_SYNCHRO)
end
function s.tgcond(e,c)
	return Duel.IsExistingMatchingCard(s.fspfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end