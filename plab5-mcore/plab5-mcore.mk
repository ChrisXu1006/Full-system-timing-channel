#=========================================================================
# plab5-mcore Subpackage
#=========================================================================

plab5_mcore_deps = \
  vc \
  pisa \
  plab1-imul \
  plab2-proc \
  plab3-mem \
  plab4-net \

plab5_mcore_srcs = \
  plab5-mcore-mem-net-adapters.v \
  plab5-mcore-MemNet.v \
  plab5-mcore-ProcCacheNetBase.v \
  plab5-mcore-ProcCacheNetAlt.v \

plab5_mcore_gen_base_test_srcs = \
  plab5-mcore-ProcCacheNetBase-mngr.t.v \
  plab5-mcore-ProcCacheNetBase-addu.t.v \
  plab5-mcore-ProcCacheNetBase-lw.t.v \
  plab5-mcore-ProcCacheNetBase-bne.t.v \
  plab5-mcore-ProcCacheNetBase-beq.t.v \
  plab5-mcore-ProcCacheNetBase-addiu.t.v \
  plab5-mcore-ProcCacheNetBase-ori.t.v \
  plab5-mcore-ProcCacheNetBase-sra.t.v \
  plab5-mcore-ProcCacheNetBase-sll.t.v \
  plab5-mcore-ProcCacheNetBase-lui.t.v \
  plab5-mcore-ProcCacheNetBase-subu.t.v \
  plab5-mcore-ProcCacheNetBase-slt.t.v \
  plab5-mcore-ProcCacheNetBase-and.t.v \
  plab5-mcore-ProcCacheNetBase-or.t.v \
  plab5-mcore-ProcCacheNetBase-mul.t.v \
  plab5-mcore-ProcCacheNetBase-sw.t.v \
  plab5-mcore-ProcCacheNetBase-j.t.v \
  plab5-mcore-ProcCacheNetBase-jal.t.v \
  plab5-mcore-ProcCacheNetBase-jr.t.v \
  plab5-mcore-ProcCacheNetBase-vmh.t.v \

plab5_mcore_gen_alt_test_srcs = \
  plab5-mcore-ProcCacheNetAlt-mngr.t.v \
  plab5-mcore-ProcCacheNetAlt-addu.t.v \
  plab5-mcore-ProcCacheNetAlt-lw.t.v \
  plab5-mcore-ProcCacheNetAlt-bne.t.v \
  plab5-mcore-ProcCacheNetAlt-beq.t.v \
  plab5-mcore-ProcCacheNetAlt-addiu.t.v \
  plab5-mcore-ProcCacheNetAlt-ori.t.v \
  plab5-mcore-ProcCacheNetAlt-sra.t.v \
  plab5-mcore-ProcCacheNetAlt-sll.t.v \
  plab5-mcore-ProcCacheNetAlt-lui.t.v \
  plab5-mcore-ProcCacheNetAlt-subu.t.v \
  plab5-mcore-ProcCacheNetAlt-slt.t.v \
  plab5-mcore-ProcCacheNetAlt-and.t.v \
  plab5-mcore-ProcCacheNetAlt-or.t.v \
  plab5-mcore-ProcCacheNetAlt-mul.t.v \
  plab5-mcore-ProcCacheNetAlt-j.t.v \
  plab5-mcore-ProcCacheNetAlt-jal.t.v \
  plab5-mcore-ProcCacheNetAlt-jr.t.v \
  plab5-mcore-ProcCacheNetAlt-vmh.t.v \

plab5_mcore_test_srcs = \
  plab5-mcore-mem-net-adapters.t.v \
  plab5-mcore-MemNet.t.v \
	$(plab5_mcore_gen_base_test_srcs) \
	$(plab5_mcore_gen_alt_test_srcs) \

plab5_mcore_sim_srcs = \
   plab5-mcore-sim-base.v \
   plab5-mcore-sim-alt.v \


#-------------------------------------------------------------------------
# Rules to generate test harnesses based on instructions
#-------------------------------------------------------------------------

$(plab5_mcore_gen_base_test_srcs) : plab5-mcore-ProcCacheNetBase-%.t.v \
	: plab5-mcore-ProcCacheNetBase.t.v plab5-mcore-test-cases-%.v \
	plab5-mcore-test-harness.v
	cat $< | sed "s/%INST%/$*/g" > $@

$(plab5_mcore_gen_alt_test_srcs) : plab5-mcore-ProcCacheNetAlt-%.t.v \
	: plab5-mcore-ProcCacheNetAlt.t.v plab5-mcore-test-cases-%.v \
	plab5-mcore-test-harness.v
	cat $< | sed "s/%INST%/$*/g" > $@


#-------------------------------------------------------------------------
# Rules to run assembly tests
#-------------------------------------------------------------------------

# Directory of vmh files

test_vmh_dir = $(top_dir)/apps/tests/build/vmh-cache

# List of implementations and inputs to test

#plab5_mcore_check_vmh_impls  = ProcCacheNetBase ProcCacheNetAlt
plab5_mcore_base_check_vmh_inputs = \
  cache-parcv1-addiu \
  cache-parcv1-addu \
  cache-parcv1-bne \
  cache-parcv1-jal \
  cache-parcv1-jr \
  cache-parcv1-lui \
  cache-parcv1-lw \
  cache-parcv1-ori \
  cache-parcv1-sw \
  cache-parcv2-and \
  cache-parcv2-andi \
  cache-parcv2-beq \
  cache-parcv2-bgez \
  cache-parcv2-bgtz \
  cache-parcv2-blez \
  cache-parcv2-bltz \
  cache-parcv2-j \
  cache-parcv2-jalr \
  cache-parcv2-mul \
  cache-parcv2-nor \
  cache-parcv2-or \
  cache-parcv2-sll \
  cache-parcv2-sllv \
  cache-parcv2-slt \
  cache-parcv2-slti \
  cache-parcv2-sltiu \
  cache-parcv2-sltu \
  cache-parcv2-sra \
  cache-parcv2-srav \
  cache-parcv2-srl \
  cache-parcv2-srlv \
  cache-parcv2-subu \
  cache-parcv2-xor \
  cache-parcv2-xori \

plab5_mcore_alt_check_vmh_inputs = \
  cache-mt-simple \
  cache-mt-addiu \
  cache-mt-addu \
  cache-mt-bne \
  cache-mt-jal \
  cache-mt-jr \
  cache-mt-lui \
  cache-mt-lw \
  cache-mt-ori \
  cache-mt-and \
  cache-mt-andi \
  cache-mt-beq \
  cache-mt-bgez \
  cache-mt-bgtz \
  cache-mt-blez \
  cache-mt-bltz \
  cache-mt-j \
  cache-mt-jalr \
  cache-mt-mul \
  cache-mt-nor \
  cache-mt-or \
  cache-mt-sll \
  cache-mt-sllv \
  cache-mt-slt \
  cache-mt-slti \
  cache-mt-sltiu \
  cache-mt-sltu \
  cache-mt-sra \
  cache-mt-srav \
  cache-mt-srl \
  cache-mt-srlv \
  cache-mt-subu \
  cache-mt-xor \
  cache-mt-xori \
  cache-mt-amo-add \
  cache-mt-amo-and \
  cache-mt-amo-or \

# Template used to create rules for each impl/input pair

define plab5_mcore_check_vmh_template

plab5_mcore_check_vmh_outs += plab5-mcore-$(1)-$(2)-vmh-test.out

plab5-mcore-$(1)-$(2)-vmh-test.out : plab5-mcore-$(1)-vmh-test
	./$$< +exe=$(test_vmh_dir)/$(2).vmh +verbose=2 | sed "s/$(1)/$(1)-$(2)/g" > $$@
endef

# Call template for each impl/input pair

#$(foreach impl,$(plab5_mcore_check_vmh_impls), \
#  $(foreach dataset,$(plab5_mcore_check_vmh_inputs), \
#    $(eval $(call plab5_mcore_check_vmh_template,$(impl),$(dataset)))))

$(foreach dataset,$(plab5_mcore_base_check_vmh_inputs), \
  $(eval $(call plab5_mcore_check_vmh_template,ProcCacheNetBase,$(dataset))))

$(foreach dataset,$(plab5_mcore_alt_check_vmh_inputs), \
  $(eval $(call plab5_mcore_check_vmh_template,ProcCacheNetAlt,$(dataset))))

# Generate summary and use the script to print the pass/fail

plab5-mcore-check-vmh-summary.out : $(plab5_mcore_check_vmh_outs)
	cat $^ > $@


plab5_mcore_junk += $(plab5_mcore_check_vmh_outs) \
	plab5-mcore-check-vmh-summary.out


check-vmh-plab5-mcore : plab5-mcore-check-vmh-summary.out
	$(scripts_dir)/test-summary --verbose $<

.PHONY : check-vmh-plab5-mcore

#-------------------------------------------------------------------------
# Evaluation
#-------------------------------------------------------------------------

# Directory of vmh files

eval_vmh_dir = $(top_dir)/apps/ubmark/build/vmh-cache

# List of implementations and inputs to evaluate

plab5_mcore_base_eval_inputs = \
  cache-ubmark-vvadd \
  cache-ubmark-cmplx-mult \
  cache-ubmark-bin-search \
  cache-ubmark-masked-filter \
  cache-ubmark-quicksort \

plab5_mcore_alt_eval_inputs = \
  cache-mtbmark-vvadd \
  cache-mtbmark-cmplx-mult \
  cache-mtbmark-bin-search \
  cache-mtbmark-masked-filter \
  cache-mtbmark-sort \


# Template used to create rules for each impl/input pair

define plab5_mcore_eval_template

plab5_mcore_eval_outs += plab5-mcore-sim-$(1)-$(2).out

plab5-mcore-sim-$(1)-$(2).out : plab5-mcore-sim-$(1) $(eval_vmh_dir)/$(2).vmh
	./$$< +exe=$(eval_vmh_dir)/$(2).vmh +stats | tee $$@

endef

$(foreach dataset,$(plab5_mcore_base_eval_inputs), \
  $(eval $(call plab5_mcore_eval_template,base,$(dataset))))

$(foreach dataset,$(plab5_mcore_alt_eval_inputs), \
  $(eval $(call plab5_mcore_eval_template,alt,$(dataset))))

plab5_mcore_junk += $(plab5_mcore_eval_outs)

# Grep all evaluation results

eval-plab5-mcore : $(plab5_mcore_eval_outs)
	@echo ""
	@echo "Verify:"
	@grep "\[ passed \]\|\[ FAILED \]" $^ | column -s ":=" -t
	@echo ""
	@echo "Num cycles:"
	@grep "\<num_cycles\>" $^ | column -s ":=" -t
	@echo ""


#+++ gen-harness : begin cut +++++++++++++++++++++++++++++++++++++++++++++

#-------------------------------------------------------------------------
# Rules to generate harness
#-------------------------------------------------------------------------

# hacky: to be able to cut ubmark-quicksort.c, we first copy it to here
plab5-mcore-harness :
	cp $(top_dir)/apps/ubmark/ubmark/ubmark-quicksort.c $(top_dir)/plab5-mcore/
	cp $(top_dir)/apps/ubmark/mtbmark/mtbmark-sort.c $(top_dir)/plab5-mcore/
	$(scripts_dir)/gen-harness --verbose \
    ece4750-lab5-mcore \
    $(src_dir) \
    $(src_dir)/plab5-mcore/plab5-mcore-gen-harness-cfg
	cd ece4750-lab5-mcore/ ; \
	mkdir apps; \
	cd apps; \
	cp -r ../../../apps/tests tests; \
	rm -rf tests/build; \
	rm -rf tests/build-native; \
	cp -r ../../../apps/ubmark ubmark; \
	rm -rf ubmark/build; \
	rm -rf ubmark/build-native; \
	mv ../plab5-mcore/ubmark-quicksort.c ubmark/ubmark/; \
	mv ../plab5-mcore/mtbmark-sort.c ubmark/mtbmark/; \
	cd ../..; \
	tar czvf ece4750-lab5-mcore.tar.gz ece4750-lab5-mcore
	rm $(top_dir)/plab5-mcore/ubmark-quicksort.c
	rm $(top_dir)/plab5-mcore/mtbmark-sort.c


lab5-mcore-harness : plab5-mcore-harness

.PHONY: plab5-mcore-harness

plab5_mcore_junk += ece4750-lab5-mcore ece4750-lab5-mcore.tar.gz

#+++ gen-harness : end cut +++++++++++++++++++++++++++++++++++++++++++++++
