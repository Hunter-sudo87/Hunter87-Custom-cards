--Ivlis
--
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
--dark synchro summon 
	Synchro.AddDarkSynchroProcedure(c,Synchro.NonTuner(Card.IsSetCard,0x7df),nil,10)
	--copy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	--e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.copycon)
	e1:SetTarget(s.copytg)
	e1:SetOperation(s.copyop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_SSET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Special Summon this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CUSTOM+id)
e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.selfsptg)
	e3:SetOperation(s.selfspop)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_NEGATED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	if de then
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,dp,0,0)
	end
end
s.listed_series={0x7df,0x600}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_SYNCHRO,scard,sumtype,tp) and 
c:IsSetCard(0x7df,scard,sumtype,tp)
end
function s.copycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and (Duel.IsMainPhase() or Duel.IsBattlePhase())
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_REMOVED) and chkc:IsMonster() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsMonster,tp,0,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsMonster,tp,0,LOCATION_REMOVED,1,1,nil)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsType(TYPE_TOKEN) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e2)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,1)
		end
end
end
--destroy
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+3,0x7df+0x600,TYPES_TOKEN+TYPE_TUNER,1500,2000,11,RACE_FAIRY,ATTRIBUTE_DARK) end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsPlayerCanSpecialSummonMonster(tp,id+3,0x7df+0x600,TYPES_TOKEN+TYPE_TUNER,1500,2000,11,RACE_FAIRY,ATTRIBUTE_DARK) then
		local c=e:GetHandler()
		local token=Duel.CreateToken(tp,id+3,0x7df+0x600,TYPES_TOKEN+TYPE_TUNER,1500,2000,11,RACE_FAIRY,ATTRIBUTE_DARK)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
end
	Duel.SpecialSummonComplete()
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.disfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7df) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_SYNCHRO)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetChainLimit(s.chlimit)
end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	if #g>0 and c:IsRelateToEffect(e) and
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0  then
 Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
end
function s.matfilter1(c,syncard)
	return c:IsSetCard(0x7df) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.matfilter2(c,syncard)
	return c:IsSetCard(0x7df) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.tmatfilter(c,sc)
	return c:IsSetCard(0x600) and c:IsType(TYPE_TUNER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSynchroMaterial(sc)
end
function s.ntmatfilter(c,sc,tp)
	return c:IsSetCard(0x7df) and c:IsNotTuner(sc,tp) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSynchroMaterial(sc)
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
