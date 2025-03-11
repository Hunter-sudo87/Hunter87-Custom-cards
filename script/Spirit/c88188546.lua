--Shinato Spiritual Ark
--
local s,id=GetID()
function s.initial_effect(c)
	--Activate
		Ritual.AddProcGreater({handler=c,filter=s.ritualfil,extrafil=s.extrafil,extraop=s.extraop,extratg=s.extratg,stage2=s.stage2})
end
function s.ritualfil(c)
	return (c:IsCode(88188547) or c:IsCode(86327225)) and c:IsRitualMonster()
end
function s.mfilter(c)
	return c:HasLevel() and c:IsType(TYPE_SPIRIT) and c:IsAbleToDeck()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):Filter(Card.IsType,nil,TYPE_SPIRIT)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoDeck(mat2,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
		local c=e:GetHandler()
		--Cannot be destroyed
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
	    e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
     	e1:SetCountLimit(1)
	    e1:SetValue(s.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		--Dont leave
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
end
function s.valcon(e,re,r,rp)
	return (r&REASON_BATTLE+REASON_EFFECT)~=0
end
