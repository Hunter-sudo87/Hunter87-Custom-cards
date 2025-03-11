--Kiyohime
local s,id=GetID()
function s.initial_effect(c)
	local sme,soe=Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--Mandatory return
	sme:SetDescription(aux.Stringid(id,0))
	sme:SetCondition(s.mretcon)
	sme:SetTarget(s.mrettg)
	sme:SetOperation(s.mretop)
	--Optional return
	soe:SetCondition(aux.AND(aux.NOT(s.icecon),Spirit.OptionalReturnCondition))
	--Cannot be Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Flip 1 monster face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end
function s.thfilter1(c)
	return (c:IsType(TYPE_SPIRIT) and c:IsMonster()) or c:IsCode(88188544) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.icecon(e,tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_SPIRIT),tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.mretcon(e,tp,eg,ep,ev,re,r,rp)
	return Spirit.CommonCondition(e) and (s.icecon(e,tp) or Spirit.MandatoryReturnCondition(e))
end
function s.mrettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	if s.icecon(e,tp) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:GetHandler():ResetFlagEffect(FLAG_SPIRIT_RETURN)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetProperty(0)
		Spirit.MandatoryReturnTarget(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function s.mretop(e,tp,eg,ep,ev,re,r,rp)
	if not e:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return Spirit.ReturnOperation(e,tp,eg,ep,ev,re,r,rp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPIRIT) and c:IsMonster()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_ONFIELD,1,nil) end
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
end
