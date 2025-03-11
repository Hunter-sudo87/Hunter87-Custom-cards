--The Winged Toon Dragon of Ra 
--
Duel.EnableUnofficialProc(PROC_RA_DEFUSION)
Duel.EnableUnofficialProc(PROC_DIVINE_HIERARCHY)
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Special Summon Limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Special summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN+CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon1)
	e3:SetTarget(s.destg1)
	e3:SetOperation(s.desop1)
	c:RegisterEffect(e3)
	--Resurrection
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE) end)
	e4:SetTarget(s.immortal)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e5)
	--Tribute 1 monster or destroy this card
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(78371393,1))
	e9:SetCategory(CATEGORY_RELEASE+CATEGORY_TOGRAVE)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e9:SetCode(EVENT_PHASE+PHASE_END)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCountLimit(1)
	e9:SetCondition(s.descon2)
	e9:SetTarget(s.destg2)
	e9:SetOperation(s.desop2)
	c:RegisterEffect(e9)
	--half damage
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e10:SetCondition(s.dcon)
	e10:SetValue(c:GetAttack()/2)
	c:RegisterEffect(e10)
	--Direct attack
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetCode(EFFECT_DIRECT_ATTACK)
	e11:SetCondition(s.dircon)
	c:RegisterEffect(e11)
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e12:SetCondition(s.atcon)
	e12:SetValue(s.atlimit)
	c:RegisterEffect(e12)
	--Destroy itself
	local e13=Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e13:SetRange(LOCATION_MZONE)
	e13:SetCode(EVENT_LEAVE_FIELD)
	e13:SetCondition(s.sdescon)
	e13:SetOperation(s.sdesop)
	c:RegisterEffect(e13)
end
s.listed_series={0x62}
s.toss_coin=true
function s.rfilter(c,tp)
	return c:IsType(TYPE_TOON) and (c:IsControler(tp) or c:IsFaceup())
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp):Filter(s.rfilter,nil,tp)
	return aux.SelectUnselectGroup(rg,e,tp,3,3,aux.ChkfMMZ(1),0)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp):Filter(s.rfilter,nil,tp)
	local mg=aux.SelectUnselectGroup(rg,e,tp,3,3,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #mg==3 then
		mg:KeepAlive()
		e:SetLabelObject(mg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.descon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.CallCoin(tp) then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
    e1:SetValue(4000)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
    c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		c:RegisterEffect(e2)
	else
		local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		Duel.Destroy(g,REASON_EFFECT)
			Duel.Damage(tp,4000,REASON_EFFECT)
	end
end
--Resurrection
function s.immortal(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=Duel.SelectEffect(tp,
		{s.payatkcost(e,tp,eg,ep,ev,re,r,rp,0),aux.Stringid(id,0)},
		{true,aux.Stringid(id,1)},
		{true,aux.Stringid(id,2)})
	if op==1 then
		s.payatkcost(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetOperation(s.payatkop)
	elseif op==2 then
		e:SetOperation(s.egpop)
	else
		e:SetOperation(nil)
	end
end
-------------------------------------------
--One Turn Kill
function s.payatkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lpCost=Duel.GetLP(tp)-1
	if chk==0 then return lpCost>0 and Duel.CheckLPCost(tp,lpCost) end
	e:SetLabel(lpCost)
	Duel.PayLPCost(tp,lpCost)
end
function s.payatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lp=e:GetLabel()
	if c:IsFaceup() then
		--Fuse ATK/DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.dfcon)
		e1:SetValue(c:GetBaseAttack()+lp)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(c:GetBaseDefense()+lp)
		c:RegisterEffect(e2)
		--Treated as Fusion
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCondition(s.dfcon)
		e3:SetValue(TYPE_FUSION)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e3)
		--Tribute for stats
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,3))
		e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
		e4:SetType(EFFECT_TYPE_QUICK_O)
		e4:SetCode(EVENT_FREE_CHAIN)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCondition(s.dfcon)
		e4:SetCost(s.tatkcost)
		e4:SetOperation(s.tatkop)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e4)
		--LP is stats
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_RECOVER)
		e5:SetRange(LOCATION_MZONE)
		e5:SetCondition(s.dfcon)
		e5:SetOperation(s.atkop1)
		e5:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e5)
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_CHAIN_END)
		e6:SetRange(LOCATION_MZONE)
		e6:SetCondition(s.dfcon)
		e6:SetOperation(s.atkop2)
		e6:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e6)
		--Attack all
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetRange(LOCATION_MZONE)
		e7:SetTargetRange(0,LOCATION_MZONE)
		e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e7:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
		e7:SetCondition(s.dfcon)
		e7:SetTarget(function(_e,_c) return _c:GetFlagEffect(id+100)>0 end)
		e7:SetValue(function(_e,_c) return _c==_e:GetHandler() end)
		e7:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e7)
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e8:SetCode(EVENT_DAMAGE_STEP_END)
		e8:SetCondition(s.dfcon)
		e8:SetOperation(s.dirop)
		e8:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e8)
		local e9=Effect.CreateEffect(c)
		e9:SetType(EFFECT_TYPE_SINGLE)
		e9:SetCode(EFFECT_EXTRA_ATTACK)
		e9:SetValue(9999)
		e9:SetCondition(s.dfcon)
		e9:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e9)
		local e10=Effect.CreateEffect(c)
		e10:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e10:SetCode(EVENT_DAMAGE_STEP_END)
		e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e10:SetCondition(s.dfcon)
		e10:SetOperation(s.unop)
		e10:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e10)
	end
end
s.listed_series={0x62}
s.listed_names={15259703}
function s.dfcon(e)
	if e:GetHandler():HasFlagEffect(FLAG_RA_DEFUSION) then
		e:Reset()
		return false
	end
	return true
end
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	if ep==1-tp then return end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.dfcon)
	e1:SetValue(ev)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	Duel.SetLP(tp,1,REASON_EFFECT)
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local lp=Duel.GetLP(tp)
	if lp<=1 then return end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.dfcon)
	e1:SetValue(lp-1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	Duel.SetLP(tp,1,REASON_EFFECT)
end
function s.tatkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,e:GetHandler()) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,99,false,nil,e:GetHandler())
	local suma=0
	local sumd=0
	for tc in g:Iter() do
		suma=suma+tc:GetAttack()
		sumd=sumd+tc:GetDefense()
	end
	e:SetLabel(suma,sumd)
	Duel.Release(g,REASON_COST)
end
function s.tatkop(e,tp,eg,ep,ev,re,r,rp)
	if not s.dfcon(e) then return end
	local c=e:GetHandler()
	local atk,def=e:GetLabel()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.dfcon)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetCondition(s.dfcon)
	e2:SetValue(def)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e2)
end
function s.unop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		bc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE,0,1)
	end
end
function s.dirop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetAttackTarget() then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetCondition(s.dfcon)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
-------------------------------------------
--God Phoenix
function s.egpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		--Treated as God Phoenix
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_CHANGE_CODE)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetValue(511000237)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e0)
		--Immunities
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(s.imfilter)
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e3:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_RITUAL))
		c:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e4:SetValue(1)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e4)
		--Send to Graveyard
		local e5=Effect.CreateEffect(c)
		e5:SetDescription(aux.Stringid(id,4))
		e5:SetCategory(CATEGORY_TOGRAVE)
		e5:SetType(EFFECT_TYPE_QUICK_O)
		e5:SetCode(EVENT_FREE_CHAIN)
		e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e5:SetRange(LOCATION_MZONE)
		e5:SetCondition(s.tgcon)
		e5:SetCost(s.tgcost)
		e5:SetTarget(s.tgtg)
		e5:SetOperation(s.tgop)
		e5:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e5)
	end
end
function s.leaveChk(c,category)
	local ex,tg=Duel.GetOperationInfo(0,category)
	return ex and tg~=nil and tg:IsContains(c)
end
function s.imfilter(e,te)
	local c=e:GetOwner()
	return (c:GetDestination()>0 and c:GetReasonEffect()==te)
		or (s.leaveChk(c,CATEGORY_TOHAND) or s.leaveChk(c,CATEGORY_DESTROY) or s.leaveChk(c,CATEGORY_REMOVE)
		or s.leaveChk(c,CATEGORY_TODECK) or s.leaveChk(c,CATEGORY_RELEASE) or s.leaveChk(c,CATEGORY_TOGRAVE))
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsHasEffect(EFFECT_UNSTOPPABLE_ATTACK) or (not c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not c:IsHasEffect(EFFECT_FORBIDDEN) and not c:IsHasEffect(EFFECT_CANNOT_ATTACK)
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ATTACK))
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if not tc:GetFlagEffectLabel(513000065)
		or (c:GetFlagEffectLabel(513000065) and c:GetFlagEffectLabel(513000065)>=tc:GetFlagEffectLabel(513000065)) then
		e:SetProperty(e:GetProperty()|EFFECT_FLAG_IGNORE_IMMUNE)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		tc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		tc:RegisterEffect(e3,true)
		Duel.AdjustInstantly(c)
	end
	Duel.SendtoGrave(tc,REASON_EFFECT)
	e:SetProperty(e:GetProperty()&~EFFECT_FLAG_IGNORE_IMMUNE)
end
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsLocation(LOCATION_DECK) end
	if not Duel.CheckReleaseGroup(tp,nil,2,c) then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,2,0,0)
	end
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	if Duel.CheckReleaseGroup(tp,Card.IsReleasableByEffect,2,c) and Duel.SelectYesNo(tp,aux.Stringid(78371393,2)) then
		local g=Duel.SelectReleaseGroup(tp,Card.IsReleasableByEffect,2,2,c)
		Duel.Release(g,REASON_EFFECT)
	else Duel.SendtoGrave(c,REASON_EFFECT) end
end
function s.dcon(e)
	return Duel.GetAttackTarget()==nil
end
function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function s.dircon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		and not Duel.IsExistingMatchingCard(s.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
function s.atcon(e)
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
function s.atlimit(e,c)
	return not c:IsType(TYPE_TOON) or c:IsFacedown()
end
function s.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sfilter,1,nil)
end
function s.sdesop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end