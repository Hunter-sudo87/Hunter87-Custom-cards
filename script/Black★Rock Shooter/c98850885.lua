--Otherworld Underworld Cygnus
--
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddDarkSynchroProcedure(c,Synchro.NonTuner(Card.IsSetCard,0x620),nil,9)
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
	--pendulum set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(aux.bdogcon)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,3})
	e4:SetTarget(s.reptg)
	c:RegisterEffect(e4)
	--Negate monster effect activation and special summon 1 Xyz monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,4})
	e5:SetCondition(s.discon)
	e5:SetTarget(s.distg)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
end
s.listed_series={0x620}
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x620) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x620) and not c:IsForbidden()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.filter(c)
	return c:IsSetCard(0x620) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReason(REASON_BATTLE) and Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_PZONE,0,1,nil) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_PZONE,0,1,1,nil)
		Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_PZONE|LOCATION_EXTRA)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and  c:IsSetCard(0x620) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_PZONE|LOCATION_EXTRA,0,nil,e,tp)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.tmatfilter(c,sc)
	return c:IsSetCard(0x600) and c:IsType(TYPE_TUNER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSynchroMaterial(sc)
end
function s.ntmatfilter(c,sc,tp)
	return c:IsSetCard(0x620) and c:IsNotTuner(sc,tp) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSynchroMaterial(sc)
end
function s.synfilter1(c,lv,tuner,sc,pe,tc)
	if sc:GetFlagEffect(100000147)==0 then
		return tuner:IsExists(s.synfilter2,1,c,true,lv,c,sc,pe,tc)
	else
		return tuner:IsExists(s.synfilter2,1,c,false,lv,c,sc,pe,tc)
	end
end
function s.synfilter2(c,add,lv,ntng,sc,pe,tc)    
	if pe and not Group.FromCards(ntng,c):IsContains(pe:GetOwner()) then return false end
	if tc and not Group.FromCards(ntng,c):IsContains(tc) then return false end
	if c.tuner_filter and not c.tuner_filter(ntng) then return false end
	if ntng.tuner_filter and not ntng.tuner_filter(c) then return false end
	if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) and ntng:IsLocation(LOCATION_HAND) then return false end
	if not ntng:IsHasEffect(EFFECT_HAND_SYNCHRO) and c:IsLocation(LOCATION_HAND) then return false end
	if (ntng:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO)) and c:IsLocation(LOCATION_HAND) 
		and ntng:IsLocation(LOCATION_HAND) then return false end
        
    local tp=sc:GetControler()
	if sc:IsLocation(LOCATION_EXTRA) then
        local sg=Group.CreateGroup()
        sg:AddCard(ntng)
        sg:AddCard(c)
		if Duel.GetLocationCountFromEx(tp,tp,sg,sc)<=0 then return false end
	else
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
            and not Group.FromCards(ntng,c):IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then return false end
	end
    
	local ntlv=ntng:GetSynchroLevel(sc)
	local lv1=bit.band(ntlv,0xffff)
	local lv2=bit.rshift(ntlv,16)
	if add then
		return c:GetSynchroLevel(sc)==lv+lv1 or c:GetSynchroLevel(sc)==lv+lv2
	else
		return c:GetSynchroLevel(sc)==lv-lv1 or c:GetSynchroLevel(sc)==lv-lv2
	end
end
function s.syncon(e,c,tuner,mg)
	if c==nil then return true end
    local lvsyn=e:GetHandler():GetLevel()
	local tp=c:GetControler()
	local pe=Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_MATERIAL)
	local tng=Duel.GetMatchingGroup(s.tmatfilter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,c)
	local ntng=Duel.GetMatchingGroup(s.ntmatfilter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,c,tp)    
	return ntng:IsExists(s.synfilter1,1,nil,lvsyn,tng,c,pe,tuner)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp,c,tuner,mg)
    local lvsyn=e:GetHandler():GetLevel()
	local pe=Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_MATERIAL)
	local g=Group.CreateGroup()
	local tun=Duel.GetMatchingGroup(s.tmatfilter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,c)
	local nont=Duel.GetMatchingGroup(s.ntmatfilter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,c,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local nontmat=nont:FilterSelect(tp,s.synfilter1,1,1,nil,lvsyn,tun,c,pe,tuner)
	local mat1=nontmat:GetFirst()
	g:AddCard(mat1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local t
	if mat1:GetFlagEffect(100000147)==0 then
		t=tun:FilterSelect(tp,s.synfilter2,1,1,mat1,true,lvsyn,mat1,c,pe,tuner)
	else
		t=tun:FilterSelect(tp,s.synfilter2,1,1,mat1,false,lvsyn,mat1,c,pe,tuner)
	end
	g:Merge(t)
	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
	g:DeleteGroup()
end
