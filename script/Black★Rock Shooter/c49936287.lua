--Governor - B★R☆S
--Sripted by Hunter87
--if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s, id = GetID()
s.ReverseXyz = true
--if not REVERSE_XYZ_IMPORTED then Duel.LoadScript("proc_reverse_xyz.lua") end
function s.initial_effect(c)
	c:EnableReviveLimit()
--	ReverseXyz.AddProcedure(c,5,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR),aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR))
Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(s.ffilter),2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit1)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1, 0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	--overscale
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(id)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
	--Attach 1 card from your GY to this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.attcon)
	e3:SetTarget(s.atttg)
	e3:SetOperation(s.attop)
	c:RegisterEffect(e3)
end
s.listed_series ={0x620}
s.pendulum_level=5
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x620,fc,sumtype,tp) and c:IsLevel(5)
end
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit1(e,se,sp,st)
	local c=e:GetHandler()
	return not (c:IsLocation(LOCATION_EXTRA) and c:IsFacedown())
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x620) and (sumtp & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
end
function s.spcon(e)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil,0x601)
end
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.gyfilter(c,typ)
    return c:IsType(typ) and c:IsAbleToChangeControler()
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local typ=0
    if re:IsActiveType(TYPE_MONSTER) then typ=TYPE_MONSTER end
    if re:IsActiveType(TYPE_SPELL) then typ=TYPE_SPELL end
    if re:IsActiveType(TYPE_TRAP) then typ=TYPE_TRAP end
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,typ) 
    end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local typ=0
    if re:IsActiveType(TYPE_MONSTER) then typ=TYPE_MONSTER end
    if re:IsActiveType(TYPE_SPELL) then typ=TYPE_SPELL end
    if re:IsActiveType(TYPE_TRAP) then typ=TYPE_TRAP end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,typ)
    if #g>0 then
        Duel.Overlay(c,g)
        local tc=g:GetFirst()
        if typ==TYPE_MONSTER then
            -- Gain ATK equal to the attached monster's ATK
            local atk=tc:GetAttack()
            if atk>0 then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(atk)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                c:RegisterEffect(e1)
            end
        elseif typ==TYPE_SPELL then
            -- Reduce opponent's monsters' ATK
            local ct=c:GetOverlayCount()
            local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
            for tc in aux.Next(g) do
                local e2=Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_UPDATE_ATTACK)
                e2:SetValue(-500*ct)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                tc:RegisterEffect(e2)
            end
        elseif typ==TYPE_TRAP then
            -- Cannot be destroyed by card effects
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e3:SetValue(1)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e3)
        end
    end
end
