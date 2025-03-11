--Darklord Domain
--
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Tribute Summon by sending 1 of your monsters and 1 opponent's card to the GY
local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SUMMON_PROC)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_HAND,0)
    e2:SetCondition(s.otcon)
    e2:SetTarget(aux.FieldSummonProcTg(s.ottg,s.sumtg))
    e2:SetOperation(s.otop)
    e2:SetValue(SUMMON_TYPE_TRIBUTE)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_SET_PROC)
    c:RegisterEffect(e3)
	--Add 1 Level 6 or higher monster to the hand, then Normal Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(70894,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--cannot be destroyed by effects
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(s.con)
	e5:SetTarget(s.target)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
s.listed_names={25451652}
function s.rescon(sg,e,tp,mg)
    return sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)==1
end
function s.rmfilter(c,e)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function s.otcon(e,c,minc)
    if c==nil then return true end
    local tp=c:GetControler()
    local rg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,0,nil,e)
    return minc<=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and aux.SelectUnselectGroup(rg+Duel.GetReleaseGroup(tp,false,false,REASON_EFFECT),e,tp,2,2,s.rescon,0)
end
function s.ottg(e,c)
    local mi,ma=c:GetTributeRequirement()
    return mi<=2 and ma>=2
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,c)
    local rg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,0,nil,e)
    local sg=aux.SelectUnselectGroup(rg+Duel.GetReleaseGroup(tp,false,false,REASON_EFFECT),e,tp,2,2,s.rescon,1,tp,HINTMSG_SELECT)
    if #sg>0 then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    if not sg then return end
    local rg,tg=sg:Split(Card.IsLocation,nil,LOCATION_GRAVE)
    Duel.Remove(rg,REASON_EFFECT,POS_FACEUP)
    Duel.Release(tg,REASON_EFFECT|REASON_RELEASE)
    sg:DeleteGroup()
end
function s.thfilter(c)
	return c:IsLevelAbove(6) and c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonableCard() and c:IsAbleToHand()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() 		and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_DARK)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		if tc:IsSummonable(true,nil,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Summon(tp,tc,true,nil,1)
		end
	end
end
function s.atfilter(c)
	return c:IsFaceup() and c:IsCode(25451652)
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.atfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.target(e,c)
	return c:IsSummonType(SUMMON_TYPE_TRIBUTE) and c:IsAttribute(ATTRIBUTE_DARK)
end
