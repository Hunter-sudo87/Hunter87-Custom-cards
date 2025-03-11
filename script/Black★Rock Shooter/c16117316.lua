--Insane.Black★Rock Mecha☆Shooter -B★R☆S
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x620),1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
	--Xyz Summon
Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x620), 9, 3,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	--level/rank
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_RANK_LEVEL_S)
	c:RegisterEffect(e0)
    --Ritual Summon tributing 3 Ritual monsters you control with different names
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
e1:SetRange(LOCATION_EXTRA)
e1:SetValue(SUMMON_TYPE_RITUAL)
	e1:SetCondition(s.hybcon)
	e1:SetOperation(s.hybop)
	c:RegisterEffect(e1)
	--synchro level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e2:SetRange(LOCATION_EXTRA)
e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)
    -- Negate effects if Synchro Summoned using only Synchro Monsters
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.negcon)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
    -- Detach 5 materials and banish all opponent's cards
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(s.banishcon)
    e4:SetCost(s.banishcost)
    e4:SetTarget(s.banishtg)
    e4:SetOperation(s.banishop)
    c:RegisterEffect(e4)
    -- Take control of all opponent's monsters
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_CONTROL)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCondition(s.controlcon)
    e5:SetTarget(s.controltg)
    e5:SetOperation(s.controlop)
    c:RegisterEffect(e5)
    -- Special Summon "Otherworld" monster when this card leaves the field
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,0))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_LEAVE_FIELD)
    e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e6:SetCondition(s.spcon)
    e6:SetTarget(s.sptg)
    e6:SetOperation(s.spop)
    c:RegisterEffect(e6)
end
s.listed_series={0x620}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_SYNCHRO,scard,sumtype,tp) and 
c:IsSetCard(0x620,scard,sumtype,tp)
end
function s.ovfilter(c,tp,xyzc)
	return c:IsSetCard(0x620,lc,SUMMON_TYPE_XYZ,tp) and c:IsFaceup()
	       and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.hybfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x620) and c:IsAbleToGraveAsCost()
end
function s.hybcon(e,c)
	if c==nil then return true end
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	local g=Duel.GetMatchingGroup(s.hybfilter,c:GetControler(),LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>=3
end
function s.hybop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.hybfilter,tp,LOCATION_MZONE,0,nil)
	local rg=Group.CreateGroup()
	for i=1,3 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc then
			rg:AddCard(tc)
			g:Remove(Card.IsCode,nil,tc:GetCode())
		end
	end
	Duel.SendtoGrave(rg,REASON_COST)
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
    local ct=#sg
    local res=sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,sc)
        or sg:CheckWithSumEqual(Card.GetSynchroLevel,lv-9,ct-3,ct-3,sc)
    return res,true
end
-- Condition: Check if the card was Synchro Summoned using only Synchro Monsters
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterial():FilterCount(Card.IsType,nil,TYPE_SYNCHRO)==c:GetMaterialCount()
end

-- Operation: Negate the effects of all face-up cards your opponent controls until the end of this turn
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,c)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- Condition: Check if the card was Xyz Summoned
function s.banishcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

-- Cost: Detach 5 materials from this card
function s.banishcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,5,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,5,5,REASON_COST)
end

-- Target: Set operation info for banishing
function s.banishtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end

-- Operation: Banish all opponent's cards and gain ATK
function s.banishop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
    if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
        local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
        if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
            local atk=ct*1000
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
        end
    end
end

-- Condition: Check if the card was Ritual Summoned using only Ritual Monsters
function s.controlcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:GetMaterial():FilterCount(Card.IsType,nil,TYPE_RITUAL)==c:GetMaterialCount()
end

-- Target: Set operation info for taking control
function s.controltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,#g,0,0)
end

-- Operation: Take control of all opponent's monsters
function s.controlop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.GetControl(g,tp)
    end
end
-- Condition: Check if the summoned card leaves the field
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

-- Target: Choose 1 "Otherworld" monster from hand, Deck, or Graveyard to Special Summon
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

-- Filter: Define "Otherworld" monsters that can be Special Summoned
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x620) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

-- Operation: Special Summon the chosen "Otherworld" monster, ignoring its summoning conditions
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
    end
end
