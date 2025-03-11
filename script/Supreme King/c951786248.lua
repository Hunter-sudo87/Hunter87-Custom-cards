--Supreme King Magician Z-ARC

local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	c:EnableUnsummonable()
	--destroy self and perform effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.Fspcost)
	e2:SetCondition(s.Fspcon)
	e2:SetTarget(s.Fsptg)
	e2:SetOperation(s.Fspop)
	c:RegisterEffect(e2)
	--Synchro
	local e3=e2:Clone()
	e3:SetCost(s.Sspcost)
	e3:SetCondition(s.Sspcon)
	e3:SetTarget(s.Ssptg)
	e3:SetOperation(s.Sspop)
	c:RegisterEffect(e3)
	--XYZ
	local e4=e2:Clone()
	e4:SetCost(s.Xspcost)
	e4:SetCondition(s.Xspcon)
	e4:SetTarget(s.Xsptg)
	e4:SetOperation(s.Xspop)
	c:RegisterEffect(e4)
	--spsummon condition
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(s.splimit)
	c:RegisterEffect(e5)
	--Becomes "Supreme King Z-ARC" while on field
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_CHANGE_CODE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(CARD_ZARC)
	c:RegisterEffect(e6)
end
s.listed_series={0x98,0x20f8,SET_SUPREME_KING_GATE}
function s.thfilter(c,e,tp)
	return (c:IsSetCard(0x98) or c:IsSetCard(SET_SUPREME_KING_GATE)) and c:IsType(TYPE_PENDULUM) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.Destroy(c,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.HintSelection(g)
		for tc in aux.Next(g) do
			local op=0
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
				op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
			else
				op=Duel.SelectOption(tp,aux.Stringid(id,1))
			end
			if op==0 then
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			else
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and (e:GetHandler():IsLocation(LOCATION_HAND) or e:GetHandler():IsLocation(LOCATION_EXTRA))
end
function s.Fcfilter(c,p)
	return c:IsType(TYPE_FUSION) and c:IsFaceup() and c:IsControler(p)
end
function s.Fspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.Fcfilter,1,nil,1-tp)
end
function s.Fspfilter(c,e,tp)
	return c:IsSetCard(0x20f8) and c:IsType(TYPE_FUSION) and c:IsLevel(10)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,true)
end
function s.Fcostfilter(c,e,tp)
	return c:IsSetCard(0x20f8) and c:IsControler(tp) and (c:IsControler(tp) and c:GetSequence()<5) and (c:IsControler(tp) or c:IsFaceup())
		and Duel.IsExistingMatchingCard(s.Fspfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.Fspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.Fcostfilter,2,false,nil,nil,e,tp) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.Fcostfilter,2,2,false,nil,nil,e,tp)
	Duel.Release(sg,REASON_COST)
end
function s.Fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.Fspfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(s.Fcostfilter,tp,LOCATION_MZONE,0,2,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.Fspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.Fspfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_FUSION,tp,tp,false,true,POS_FACEUP)
	end
end
--Synchro
function s.Scfilter(c,p)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup() and c:IsControler(p)
end
function s.Sspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.Scfilter,1,nil,1-tp)
end
function s.Sspfilter(c,e,tp)
	return c:IsSetCard(0x20f8) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(10)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,true)
end
function s.Scostfilter(c,e,tp)
	return c:IsSetCard(0x20f8) and c:IsControler(tp) and (c:IsControler(tp) and c:GetSequence()<5) and (c:IsControler(tp) or c:IsFaceup())
		and Duel.IsExistingMatchingCard(s.Sspfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.Sspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.Scostfilter,2,false,nil,nil,e,tp) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.Scostfilter,2,2,false,nil,nil,e,tp)
	Duel.Release(sg,REASON_COST)
end
function s.Ssptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.Sspfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(s.Scostfilter,tp,LOCATION_MZONE,0,2,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.Sspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.Sspfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_SYNCHRO,tp,tp,false,true,POS_FACEUP)
	end
end
--Xyz
function s.Xcfilter(c,p)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsControler(p)
end
function s.Xspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.Xcfilter,1,nil,1-tp)
end
function s.Xspfilter(c,e,tp)
	return c:IsSetCard(0x20f8) and c:IsRank(5)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,true)
end
function s.Xcostfilter(c,e,tp)
	return c:IsSetCard(0x20f8) and c:IsControler(tp) and (c:IsControler(tp) and c:GetSequence()<5) and (c:IsControler(tp) or c:IsFaceup())
		and Duel.IsExistingMatchingCard(s.Xspfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.Xspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.Xcostfilter,2,false,nil,nil,e,tp) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.Xcostfilter,2,2,false,nil,nil,e,tp)
	Duel.Release(sg,REASON_COST)
end
function s.Xsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.Xspfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(s.Xcostfilter,tp,LOCATION_MZONE,0,2,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.Xspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.Xspfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_XYZ,tp,tp,false,true,POS_FACEUP)
	end
end