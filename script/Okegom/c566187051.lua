--Igls
--
local s,id=GetID()
function s.initial_effect(c)
	--Apply the appropriate effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost1)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
	--atkdown
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- Special Summon materials used for a Synchro Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetLabel(REASON_SYNCHRO)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
	--Can be treated as a non-tuner for the Synchro Summon of a LIGHT monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_NONTUNER)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(function(_,sc) return sc and sc:IsSetCard(0x601) and sc:IsSetCard(0x7df) end)
	c:RegisterEffect(e4)
end
s.listed_series={0x7df,0x600,0x601}
function s.cfilter1(c,e,tp)
	if not (c:IsSetCard(0x7df) and c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_TUNER) and c:IsAbleToGraveAsCost()) and not c:IsCode(id) then return false end
	local hc=e:GetHandler()
	if c:IsAttribute(ATTRIBUTE_DARK) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0 and hc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	else
		return hc:IsAbleToDeck() and (hc:IsLocation(LOCATION_GRAVE) or Duel.IsPlayerCanDraw(tp,1))
	end
end
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	local label=tc:IsAttribute(ATTRIBUTE_LIGHT) and 1 or 0
	e:SetLabel(label)
	Duel.SendtoGrave(tc,REASON_COST)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local label=e:GetLabel()
	if label==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	else
		local attr=ATTRIBUTE_LIGHT
		if c:IsLocation(LOCATION_HAND) then
			attr=attr+CATEGORY_DRAW
			Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		end
		e:SetCategory(attr)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
	end
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local label=e:GetLabel()
	if label==0 and Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0 then
		--Hand: Special Summon this card
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	else
		--Deck: Place this card on the bottom of the Deck
		local loc=c:GetLocation()
		if Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and c:IsLocation(LOCATION_DECK) and loc==LOCATION_HAND then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7df) and c:IsRace(RACE_FAIRY)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)*-300
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==e:GetLabel()&REASON_SYNCHRO and c:IsSetCard(0x7df) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.mgfilter(c,e,tp,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:GetReason()&e:GetLabel()==e:GetLabel() and c:GetReasonCard()==rc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local mg=rc:GetMaterial()
	local ct=#mg
	if chk==0 then return ct<=Duel.GetLocationCount(tp,LOCATION_MZONE) and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
		and mg:FilterCount(s.mgfilter,nil,e,tp,rc)==ct end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,#mg,0,LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local mg=rc:GetMaterial()
	local ct=#mg
	if ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
		and mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,rc)==ct then
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	end
end
