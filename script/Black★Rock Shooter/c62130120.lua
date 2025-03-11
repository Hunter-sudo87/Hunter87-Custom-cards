--Black★Devil Girl - B★R☆S
--
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_PZONE)
e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetLabel(1)
	e2:SetCondition(s.otcon)
	e2:SetTarget(aux.FieldSummonProcTg(s.ottg,s.sumtg))
	e2:SetOperation(s.otop)
e2:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e3)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--Special Summon itself from the GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.target1)
	e5:SetOperation(s.operation1)
	c:RegisterEffect(e5)
	--decrease tribute
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DECREASE_TRIBUTE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_HAND,0)
	e6:SetTarget(aux.TargetBoolFunction(s.ltfilter))
	e6:SetValue(0x1)
	c:RegisterEffect(e6)
end
s.listed_series={0x620}
s.listed_names={id}
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x620) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.rmfilter(c)
	return c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c)
end
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end
function s.ottg(e,c)
	local mi=c:GetTributeRequirement()
	return mi>0 and c:IsSetCard(0x620)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,c)
	local mg1=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local mg2=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
	::restart::
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local g1=mg1:Select(tp,1,1,true,nil)
	if not g1 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local tc=mg2:SelectUnselect(g1,tp,false,false,2,2)
	if mg2:IsContains(tc) then
		g1:AddCard(tc)
		g1:KeepAlive()
		e:SetLabelObject(g1)
		return true
	end
	goto restart
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	sg:DeleteGroup()
	Duel.ResetFlagEffect(tp,id)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.sfilter1(c,e,tp)
	return c:IsLevel(5) and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x620) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.filter2(c,e)
	return c:IsMonster() and c:IsAbleToRemove() and not c:IsCode(id) and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsControler,1,nil,tp) and sg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g = Duel.GetMatchingGroup(s.filter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
	if chkc then return false end
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) and Duel.GetLocationCount(tp,LOCATION_MZONE) > 0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetTargetCards(e)
	if #sg>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.ltfilter(c)
	return c:IsSetCard(0x620) and c:IsRace(RACE_WARRIOR) and c:IsLevel(5) and c:IsType(TYPE_PENDULUM)
end