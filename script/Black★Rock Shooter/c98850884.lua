--Black★Rock Mecha☆Shooter -B★R☆S
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
--dark synchro summon 
	c:SetUniqueOnField(1,0,id)
	Synchro.AddDarkSynchroProcedure(c,Synchro.NonTuner(Card.IsSetCard,0x620),nil,9)
	-- Effect when Dark Synchro Summoned
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_IGNITION)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.bancon)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)
--activation limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.aclimit)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
	--Double damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(s.damcon)
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
	-- Gain ATK/DEF based on materials
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.matcheck)
	c:RegisterEffect(e4)
end
s.listed_series={0x620}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_SYNCHRO,scard,sumtype,tp) and 
c:IsSetCard(0x620,scard,sumtype,tp)
end
-- Condition: Only trigger if this card is Synchro Summoned
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- Target: Select 1 card in opponent's hand or Graveyard
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
	    return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_HAND+LOCATION_GRAVE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND+LOCATION_GRAVE)
end

-- Operation: Banish the selected card and gain 1000 ATK
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_HAND+LOCATION_GRAVE,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
	    local c=e:GetHandler()
	    if c:IsFaceup() and c:IsRelateToEffect(e) then
	        local e1=Effect.CreateEffect(c)
	        e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
	        e1:SetValue(1000)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	        c:RegisterEffect(e1)
	    end
	end
end
function s.aclimit(e,re,tp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
function s.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil and e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- Operation: Increase ATK/DEF based on the number of materials
function s.matcheck(e,c)
	local g=c:GetMaterial()
		local e1=Effect.CreateEffect(c)
	    e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
	    	e1:SetValue(#g*500)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
	    c:RegisterEffect(e1)
	    local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
	    c:RegisterEffect(e2)
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
