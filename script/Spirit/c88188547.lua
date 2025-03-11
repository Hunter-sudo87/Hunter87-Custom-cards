--Shinato, King of a Spiritual Plane
--
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Add 1 "Shinato" Ritual from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCost(aux.SelfRevealCost)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Banish 2 monsters on the field, including an Okegom Fairy monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{1,id})
	e2:SetTarget(s.rmvtg)
	e2:SetOperation(s.rmvop)
	c:RegisterEffect(e2)
	--Can Normal Summon 1 Spirit monster in addition to your Normal Summon/Set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPIRIT))
	c:RegisterEffect(e3)
end
s.listed_names={88188546}
function s.thfilter(c)
	return (c:IsCode(88188546)  or c:IsCode(60365591)) and c:IsAbleToHand()
end
function s.cfilter(c)
	return (c:IsPreviousLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)) 
 or (c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousTypeOnField()&TYPE_MONSTER>0)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.rmvfilter(c,e)
	return c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.fairyfilter(c,tp)
	return c:IsType(TYPE_SPIRIT) and c:IsMonster()and c:IsControler(tp) and c:IsFaceup()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.fairyfilter,1,nil,tp)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.rmvfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,3,s.rescon,0) end
	local g=aux.SelectUnselectGroup(g,e,tp,2,3,s.rescon,1,tp,HINTMSG_TOHAND)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,3,tp,0)
	Duel.SetChainLimit(function(_e,_ep,_tp) return _tp==_ep end)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
