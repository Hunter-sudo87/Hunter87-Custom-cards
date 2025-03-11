-- Ruin, Dawn of Oblivion
--
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local ritual_target_params={handler=c,lvtype=RITPROC_GREATER,filter=function(ritual_c) return (ritual_c:IsCode(72426662) or  ritual_c:IsCode(46427957)) and ritual_c~=c end,forcedselection=s.forcedselection}
	local ritual_operation_params={handler=c,lvtype=RITPROC_GREATER,filter=function(ritual_c) return (ritual_c:IsCode(72426662) or  ritual_c:IsCode(46427957)) end}
	--Ritual Summon 1 "Megalith" Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed its Level
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id)
	e0:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e0:SetCondition(function() return Duel.IsMainPhase() end)
	e0:SetCost(aux.SelfDiscardCost)
	e0:SetTarget(Ritual.Target(ritual_target_params))
	e0:SetOperation(Ritual.Operation(ritual_operation_params))
	c:RegisterEffect(e0)
	--code
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetValue(46427957)
	c:RegisterEffect(e1)
	--Add 1 listed Ritual monster from the GY to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={8198712}
s.fit_monster={46427957,72426662}
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function s.filter(c)
	return c:IsCode(8198712) and c:IsAbleToHand()
end
function s.filter2(c)
	return c:IsAbleToHand() and (c:IsCode(46427957,72426662) or c:ListsCode(46427957,72426662))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter2),tp,LOCATION_DECK,0,nil)
		if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=mg:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end