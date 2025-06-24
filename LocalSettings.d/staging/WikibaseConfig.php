<?php

$wgWBRepoSettings['formatterUrlProperty']='P49';

$wgWBRepoSettings['statementSections'] = [
  'item' => [
      'statements' => null,
      'identifiers' => [
          'type' => 'dataType',
          'dataTypes' => [ 'external-id' ],
      ],
  ],
  'property' => [
      'statements' => null,
      'constraints' => [
          'type' => 'propertySet',
          'propertyIds' => [ 'P854' ],
      ],
  ],
];

if ( $wgDBname === 'my_wiki' ) {
  wfLoadExtension( 'WikibaseQualityConstraints' );
  $wgWBQualityConstraintsSparqlEndpoint = 'https://query.staging.mardi4nfdi.org/proxy/wdqs/bigdata/namespace/wdq/sparql';
  $wgWBQualityConstraintsInstanceOfId = 'P3';                         // P31
  $wgWBQualityConstraintsSubclassOfId = 'P8';                         // P279
  $wgWBQualityConstraintsPropertyConstraintId = 'P854';               // P2302
  $wgWBQualityConstraintsExceptionToConstraintId = 'P856';            // P2303
  $wgWBQualityConstraintsConstraintStatusId = 'P857';                 // P2316
  $wgWBQualityConstraintsMandatoryConstraintId = 'Q3890';             // Q21502408
  $wgWBQualityConstraintsSuggestionConstraintId = 'Q3891';            // Q62026391
  $wgWBQualityConstraintsDistinctValuesConstraintId = 'Q3878';        // Q21502410
  $wgWBQualityConstraintsMultiValueConstraintId = 'Q3896';            // Q21510857
  $wgWBQualityConstraintsUsedAsQualifierConstraintId = 'Q3901';       // Q21510863
  $wgWBQualityConstraintsSingleValueConstraintId = 'Q3879';           // Q19474404
  $wgWBQualityConstraintsSymmetricConstraintId = 'Q3909';             // Q21510862
  $wgWBQualityConstraintsTypeConstraintId = 'Q3913';                  // Q21503250
  $wgWBQualityConstraintsValueTypeConstraintId = 'Q3910';             // Q21510865
  $wgWBQualityConstraintsInverseConstraintId = 'Q3907';               // Q21510855
  $wgWBQualityConstraintsItemRequiresClaimConstraintId = 'Q3883';     // Q21503247
  $wgWBQualityConstraintsValueRequiresClaimConstraintId = 'Q3916';    // Q21510864
  $wgWBQualityConstraintsConflictsWithConstraintId = 'Q3918';         // Q21502838
  $wgWBQualityConstraintsOneOfConstraintId = 'Q3924';                 // Q21510859
  $wgWBQualityConstraintsMandatoryQualifierConstraintId = 'Q3889';    // Q21510856
  $wgWBQualityConstraintsAllowedQualifiersConstraintId = 'Q3925';     // Q21510851
  $wgWBQualityConstraintsRangeConstraintId = 'Q3931';                 // Q21510860
  $wgWBQualityConstraintsDifferenceWithinRangeConstraintId = 'Q3928'; // Q21510854
  $wgWBQualityConstraintsCommonsLinkConstraintId = 'Q3934';           // Q21510852
  $wgWBQualityConstraintsContemporaryConstraintId = 'Q3938';          // Q25796498
  $wgWBQualityConstraintsFormatConstraintId = 'Q3885';                // Q21502404
  $wgWBQualityConstraintsUsedForValuesOnlyConstraintId = 'Q3897';     // Q21528958
  $wgWBQualityConstraintsUsedAsReferenceConstraintId = 'Q3898';       // Q21528959
  $wgWBQualityConstraintsNoBoundsConstraintId = 'Q3941';              // Q51723761
  $wgWBQualityConstraintsAllowedUnitsConstraintId = 'Q3943';          // Q21514353
  $wgWBQualityConstraintsSingleBestValueConstraintId = 'Q3902';       // Q52060874
  $wgWBQualityConstraintsAllowedEntityTypesConstraintId = 'Q3911';    // Q52004125
  $wgWBQualityConstraintsCitationNeededConstraintId = 'Q3953';        // Q54554025
  $wgWBQualityConstraintsPropertyScopeConstraintId = 'Q3900';         // Q53869507
  $wgWBQualityConstraintsLexemeLanguageConstraintId = 'Q3960';        // Q55819106
  $wgWBQualityConstraintsLabelInLanguageConstraintId = 'Q3958';       // Q108139345
  $wgWBQualityConstraintsLanguagePropertyId = 'P870';                 // P424
  $wgWBQualityConstraintsClassId = 'P665';                            // P2308
  $wgWBQualityConstraintsRelationId = 'P858';                         // P2309
  $wgWBQualityConstraintsInstanceOfRelationId = 'Q296';               // Q21503252
  $wgWBQualityConstraintsSubclassOfRelationId = 'Q298';               // Q21514624
  $wgWBQualityConstraintsInstanceOrSubclassOfRelationId = 'Q3968';    // Q30208840
  $wgWBQualityConstraintsPropertyId = 'P860';                         // P2306
  $wgWBQualityConstraintsQualifierOfPropertyConstraintId = 'P861';    // P2305
  $wgWBQualityConstraintsMinimumQuantityId = 'P863';                  // P2313
  $wgWBQualityConstraintsMaximumQuantityId = 'P718';                  // P2312
  $wgWBQualityConstraintsMinimumDateId = 'P864';                      // P2310
  $wgWBQualityConstraintsMaximumDateId = 'P865';                      // P2311
  $wgWBQualityConstraintsNamespaceId = 'P866';                        // P2307
  $wgWBQualityConstraintsFormatAsARegularExpressionId = 'P317';       // P1793
  $wgWBQualityConstraintsSyntaxClarificationId = 'P318';              // P2916
  $wgWBQualityConstraintsConstraintClarificationId = 'P880';          // P6607
  $wgWBQualityConstraintsConstraintScopeId = 'P885';                  // P4680
  $wgWBQualityConstraintsConstraintEntityTypesId = 'P885';            // P4680
  $wgWBQualityConstraintsSeparatorId = 'P886';                        // P4155
  $wgWBQualityConstraintsConstraintCheckedOnMainValueId = 'Q3980';    // Q46466787
  $wgWBQualityConstraintsConstraintCheckedOnQualifiersId = 'Q3979';   // Q46466783
  $wgWBQualityConstraintsConstraintCheckedOnReferencesId = 'Q3981';   // Q46466805
  $wgWBQualityConstraintsNoneOfConstraintId = 'Q3922';                // Q52558054
  $wgWBQualityConstraintsIntegerConstraintId = 'Q3983';               // Q52848401
  $wgWBQualityConstraintsWikibaseItemId = 'Q3908';                    // Q29934200
  $wgWBQualityConstraintsWikibasePropertyId = 'Q3952';                // Q29934218
  $wgWBQualityConstraintsWikibaseLexemeId = 'Q3951';                  // Q51885771
  $wgWBQualityConstraintsWikibaseFormId = 'Q3950';                    // Q54285143
  $wgWBQualityConstraintsWikibaseSenseId = 'Q3949';                   // Q54285715
  $wgWBQualityConstraintsWikibaseMediaInfoId = 'Q3948';               // Q59712033
  $wgWBQualityConstraintsPropertyScopeId = 'P868';                    // P5314
  $wgWBQualityConstraintsAsMainValueId = 'Q3954';                     // Q54828448
  $wgWBQualityConstraintsAsQualifiersId = 'Q3955';                    // Q54828449
  $wgWBQualityConstraintsAsReferencesId = 'Q3956';                    // Q54828450
}