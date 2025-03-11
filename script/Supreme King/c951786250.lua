--Supreme King Dragon Dark Requiem
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon procedure
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	Xyz.AddProcedure(c,s.matfilter,5,2)
    --Attach Pendulum Monsters when Xyz Summoned by Pendulum effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.attachcon)
    e1:SetTarget(s.attachtg)
    e1:SetOperation(s.attachop)
    c:RegisterEffect(e1)
	--Increase ATK and negate monsters effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--Special summon the monsters this card destroyed by battle
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.spcost)
	e4:SetCondition(aux.bdogcon)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={0x10f8,0x20f8}
function s.matfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_PENDULUM,xyz,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,xyz,sumtype,tp)
end
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:IsActiveType(TYPE_PENDULUM) and re:GetHandler():IsType(TYPE_MONSTER) and e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_EXTRA,0,2,nil) end
end
function s.attachfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x20f8)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local g=Duel.GetMatchingGroup(s.attachfilter,tp,LOCATION_EXTRA,0,nil)
    if #g>=2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
        local sg=g:Select(tp,2,2,nil)
        Duel.Overlay(c,sg)
    end
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.ovfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_PENDULUM) and c:IsLevel(4)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_ATTACK)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(s.ftarget)
	e0:SetLabel(c:GetFieldID())
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,c)
	local atk=g:GetSum(Card.GetBaseAttack)
	if c:UpdateAttack(atk)==atk and c:GetOverlayGroup():IsExists(s.ovfilter,1,nil) then
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,c)
		if #g1>0 then
			Duel.BreakEffect()
		end
		local ng=g1:Filter(Card.IsNegatableMonster,nil)
		for nc in aux.Next(ng) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			nc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			nc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(0)
		nc:RegisterEffect(e3)
			if nc:IsType(TYPE_TRAPMONSTER) then
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e4:SetReset(RESET_EVENT+RESETS_STANDARD)
				nc:RegisterEffect(e4)
			end
		end
	end
end
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		--Treat as Supreme King Dragon monster(s)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_SETCODE)
e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0x20f8)
	
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_SETCODE)
e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(0x20f8)
		tc:RegisterEffect(e2,true)
		--Negate effect(s)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4,true)
	end
	Duel.SpecialSummonComplete()
end