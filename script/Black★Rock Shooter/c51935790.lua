--Otherworld Karen
--
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x620),1,1,Synchro.NonTunerEx(Card.IsSetCard,0x620),1,99)
	c:EnableReviveLimit()
	--If Synchro Summoned, special summon up to 2 monsters from opponent's GY
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,7))
	e0:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCost(s.descost)
	e0:SetTarget(s.destg)
	e0:SetOperation(s.desop)
	c:RegisterEffect(e0)
	--WARRIOR: Special summon 1 banished monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(RACE_WARRIOR)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.immbttlcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- SPELLCASTER
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetLabel(RACE_SPELLCASTER)
e2:SetCondition(s.immbttlcon)
	e2:SetCountLimit(1,{id,2})
	e2:SetCost(s.cost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	--Check if its Synchro Materials include WARRIOR and/or SPELLCASTER monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
end
s.listed_series={0x620}
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.rmfilter(c)
	return c:IsSetCard(0x620) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,5,5,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,5,5,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,c) end
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetChainLimit(s.chainlimit)
end
function s.chainlimit(e,rp,tp)
	return tp==rp or not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,c)
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetValue(ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.immbttlcon(e)
	local c=e:GetHandler()
	return c:HasFlagEffect(id) and c:GetFlagEffectLabel(id)&e:GetLabel()>0
end
function s.exmatfilter(c,scard,sumtype,tp)
	return c:IsRace(RACE_WARRIOR|RACE_SPELLCASTER,scard,sumtype,tp)
end
function s.spchk(c,e,tp)
	return c:IsSetCard(0x620) and c:IsLevelBelow(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.check(sg,e,tp,mg)
	return sg:IsExists(s.spchk,1,nil,e,tp) and sg:GetClassCount(Card.GetCode)==#sg
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,s.check,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.check,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:FilterSelect(tp,s.spchk,1,1,nil,e,tp):GetFirst()
	if sg then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:RemoveCard(sg)
	end
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local g1=og:Filter(Card.IsControler,nil,tp):Filter(Card.IsLocation,nil,LOCATION_DECK)
	local g2=og:Filter(Card.IsControler,nil,1-tp):Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #g1>0 then
		Duel.SortDeckbottom(tp,tp,#g1)
	end
	if #g2>0 then
		Duel.SortDeckbottom(tp,1-tp,#g2)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,2,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.costfilter(c)
	return c:IsSetCard(0x620) and c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e:GetHandler():GetAttack()) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and tc:GetAttack()>c:GetAttack() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.valcheck(e,c)
	local attr=c:GetMaterial():GetBitwiseOr(Card.GetOriginalRace)&(RACE_WARRIOR|RACE_SPELLCASTER)
	if attr==0 then return end
	local index=(attr==RACE_WARRIOR and 4) or (attr==RACE_SPELLCASTER and 5) or 6
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE|RESET_TEMP_REMOVE),EFFECT_FLAG_CLIENT_HINT,1,attr,aux.Stringid(id,index))
end