--Insanity Rage
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_DISABLED)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:GetFirst():IsSetCard(0x620) and eg:GetFirst():IsControler(tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetTurnPlayer()==tp then
        Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
    end
    local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_BP_TWICE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    if Duel.GetTurnPlayer()==tp then
                local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DIRECT_ATTACK)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.ftarget)
    e2:SetLabel(c:GetFieldID())
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
        end
    end
function s.ftarget(e,c)
    return e:GetLabel()~=c:GetFieldID()
end
