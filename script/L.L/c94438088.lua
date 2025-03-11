--L.L. Security Medic
--
local s,id=GetID()
function s.initial_effect(c)
	--Can be used as material from the hand for "Power Tool" Synchro Monster or Level 7/8 Dragon Monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SYNCHRO_MAT_FROM_HAND)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetValue(s.synval)
	c:RegisterEffect(e1)
	--Add itself to the hand
	local e2=Effect.CreateEffect(c)
	--e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.lvcond)
	e2:SetTarget(s.lvltg)
	e2:SetOperation(s.lvlop)
	c:RegisterEffect(e2)
end
s.listed_series={0x107}
function s.synval(e,mc,sc) --this effect, this card and the monster to be summoned
	return sc:IsSetCard(0x107) and sc:IsType(TYPE_SYNCHRO)
end
function s.lvcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
function s.synchfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x107)
end
function s.lvltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.synchfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.synchfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,s.synchfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lvlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	local lvl=tc:GetLevel()
	if lvl==1 then return end
	local value=Duel.AnnounceNumberRange(tp,1,math.min(2,lvl+1))
	--Reduce its Level
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(value)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
