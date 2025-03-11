-- Toon Yubel - Terror Incarnate
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--You take no battle damage from battles involving this card
	local e3=e2:Clone()
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.sdescon)
	e4:SetOperation(s.sdesop)
	c:RegisterEffect(e4)
	--Your opponent takes all battle damage from battles involving this monster
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--Attack Position monsters your opponent controls that can attack must attack this card
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_MUST_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil) end)
	e6:SetTarget(aux.TargetBoolFunction(Card.IsAttackPos))
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e7:SetValue(function(e,_c) return _c==e:GetHandler() end)
	c:RegisterEffect(e7)
	--Special Summon "Yubel - The Ultimate Nightmare"
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_LEAVE_FIELD)
	e8:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e8:SetCondition(s.spcon)
	e8:SetTarget(s.sptg)
	e8:SetOperation(s.spop)
	c:RegisterEffect(e8)
	--Cannot be Special Summoned
	local e9=Effect.CreateEffect(c)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e9)
	--Protect Toon World
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EFFECT_DESTROY_REPLACE)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCountLimit(1)
	e10:SetTarget(s.reptg)
	e10:SetValue(s.repval)
	e10:SetOperation(s.repop)
	c:RegisterEffect(e10)
end
s.listed_names={15259703,4779091,243121560,510162705}
local LOCATION_HAND_DECK_GRAVE=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE
function s.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sfilter,1,nil)
end
function s.sdesop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:GetLocation()~=LOCATION_DECK
end
function s.spfilter(c,e,tp)
	return c:IsCode(510162705) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND_DECK_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND_DECK_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND_DECK_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
	end
end
	--Check for "Toon World" being destroyed
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsCode(15259703)
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end
function s.rmfilter(c)
    return c:IsMonster() and c:IsFaceup()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and Duel.CheckReleaseGroup(tp,s.rmfilter,1,c) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectReleaseGroup(tp,s.rmfilter,1,2,c)
		if #g>0 then
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		end
	else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local dt=Duel.Release(g,REASON_EFFECT+REASON_REPLACE)
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if dg==0 then return end
	if #dg>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=dg:Select(tp,1,dt,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
