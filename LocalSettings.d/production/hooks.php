<?php
use MediaWiki\Title\Title; 
use MediaWiki\MediaWikiServices;

$wgHooks['ArticleViewHeader'][] = function ( Article &$article ) {
		$content = $article->getPage()->getContent();
		if ( $content === null ) {
			return true;
		}
		if ( $content->getSize() === 0 ) {
			$article->getContext()->getOutput()->addWikiTextAsContent( '{{global}}' );
			return true;
		}
        $title = $article->getTitle();
        if ( $title->getNamespace() != 120 ) {
                return true;
        }
        try {
                $entity = \Wikibase\Repo\WikibaseRepo::getEntityLookup()->getEntity( new \Wikibase\DataModel\Entity\ItemId( $title->getText() ) );
                $siteLink = $entity->getSiteLinkList()->getBySiteId( 'mardi' );
                $name = $siteLink->getPageName();
        } catch ( Throwable $e ) {
                $name = '';
        }

        $article->getContext()->getOutput()->addWikiTextAsContent( "{{ItemWarning|$name}}" );
        return true;
};


$wgHooks['ShowSearchHitTitle'][] = function ( Title &$title, &$titleSnippet ) {
	$dbr = MediaWikiServices::getInstance()->getConnectionProvider()->getReplicaDatabase();
	$displayTitle = $dbr->selectField( 'page_props', 'pp_value', [
		'pp_propname' => 'displaytitle',
		'pp_page' => $title->getArticleId()
	] );
	if ( $displayTitle ) {
		$titleSnippet = $displayTitle;
	}
};
