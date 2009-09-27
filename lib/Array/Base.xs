#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifndef newSVpvs_share
# define newSVpvs_share(STR) newSVpvn_share(""STR"", sizeof(STR)-1, 0)
#endif /* !newSVpvs_share */

#ifndef SvSHARED_HASH
# define SvSHARED_HASH(SV) SvUVX(SV)
#endif /* !SvSHARED_HASH */

static SV *base_hint_key_sv;
static U32 base_hint_key_hash;
static OP *(*nxck_aelem)(pTHX_ OP *o);
static OP *(*nxck_aslice)(pTHX_ OP *o);
static OP *(*nxck_av2arylen)(pTHX_ OP *o);

static IV current_base(pTHX)
{
	HE *base_ent = hv_fetch_ent(GvHV(PL_hintgv), base_hint_key_sv, 0,
					base_hint_key_hash);
	return base_ent ? SvIV(HeVAL(base_ent)) : 0;
}

static OP *ck_aelem(pTHX_ OP *op)
{
	IV base;
	if((base = current_base(aTHX)) != 0) {
		OP *aop, *iop;
		if(!op->op_flags & OPf_KIDS) {
			bad_ops:
			croak("strange op tree prevents applying array base");
		}
		aop = cBINOPx(op)->op_first;
		iop = aop->op_sibling;
		if(!iop || iop->op_sibling) goto bad_ops;
		aop->op_sibling =
			newBINOP(OP_SUBTRACT, 0, iop,
				newSVOP(OP_CONST, 0, newSViv(base)));
	}
	return nxck_aelem(aTHX_ op);
}

static OP *ck_aslice(pTHX_ OP *op)
{
	IV base;
	if((base = current_base(aTHX)) != 0) {
		OP *lop, *aop, *mop;
		if(!op->op_flags & OPf_KIDS) {
			bad_ops:
			croak("strange op tree prevents applying array base");
		}
		lop = cLISTOPx(op)->op_first;
		aop = lop->op_sibling;
		if(!aop || aop->op_sibling) goto bad_ops;
		lop->op_sibling = NULL;
		mop = newLISTOP(OP_LIST, 0,
				newBINOP(OP_SUBTRACT, 0,
					newGVOP(OP_GVSV, 0, PL_defgv),
					newSVOP(OP_CONST, 0, newSViv(base))),
				lop);
		mop->op_type = OP_MAPSTART;
		mop->op_ppaddr = PL_ppaddr[OP_MAPSTART];
		mop = PL_check[OP_MAPSTART](aTHX_ mop);
#ifdef OPpGREP_LEX
		if(mop->op_type == OP_MAPWHILE) {
			mop->op_private &= ~OPpGREP_LEX;
			if(cLISTOPx(mop)->op_first->op_type == OP_MAPSTART)
				cLISTOPx(mop)->op_first->op_private &=
					~OPpGREP_LEX;
		}
#endif /* OPpGREP_LEX */
		mop->op_sibling = aop;
		cLISTOPx(op)->op_first = mop;
	}
	return nxck_aslice(aTHX_ op);
}

static OP *ck_av2arylen(pTHX_ OP *op)
{
	IV base;
	if((base = current_base(aTHX)) != 0) {
		op = nxck_av2arylen(aTHX_ op);
		return newBINOP(OP_ADD, 0, op,
				newSVOP(OP_CONST, 0, newSViv(base)));
	} else {
		return nxck_av2arylen(aTHX_ op);
	}
}

MODULE = Array::Base PACKAGE = Array::Base

BOOT:
	base_hint_key_sv = newSVpvs_share("Array::Base/base");
	base_hint_key_hash = SvSHARED_HASH(base_hint_key_sv);
	nxck_aelem = PL_check[OP_AELEM]; PL_check[OP_AELEM] = ck_aelem;
	nxck_aslice = PL_check[OP_ASLICE]; PL_check[OP_ASLICE] = ck_aslice;
	nxck_av2arylen = PL_check[OP_AV2ARYLEN];
		PL_check[OP_AV2ARYLEN] = ck_av2arylen;

void
import(SV *class, IV base)
CODE:
	PL_hints |= HINT_LOCALIZE_HH;
	gv_HVadd(PL_hintgv);
	if(base == 0) {
		hv_delete_ent(GvHV(PL_hintgv), base_hint_key_sv, G_DISCARD,
				base_hint_key_hash);
	} else {
		SV *base_sv = newSViv(base);
		HE *he = hv_store_ent(GvHV(PL_hintgv), base_hint_key_sv,
				base_sv, base_hint_key_hash);
		if(he) {
			SV *val = HeVAL(he);
			SvSETMAGIC(val);
		} else {
			SvREFCNT_dec(base_sv);
		}
	}

void
unimport(SV *class)
CODE:
	PL_hints |= HINT_LOCALIZE_HH;
	gv_HVadd(PL_hintgv);
	hv_delete_ent(GvHV(PL_hintgv), base_hint_key_sv, G_DISCARD,
			base_hint_key_hash);
